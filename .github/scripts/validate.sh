#!/usr/bin/env bash
set -euo pipefail

# CPM Package Validation Script - Package Manager for AI Agents
# Dependencies: yq (YAML parser), jq (JSON parser)
# Exit codes: 0 = all validations pass, 1 = one or more validations fail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
REGISTRY_FILE="$ROOT_DIR/registry.json"
PACKAGES_DIR="$ROOT_DIR/packages"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0

# Valid values
VALID_TYPES="skill|rules|mcp"
MCP_ALLOWED_COMMANDS="npx|node|python|uvx|docker"
ALLOWED_EXTENSIONS="md|yaml|yml|json|mdc"
MAINTAINER_NAMESPACES="cpm|cpmai|official"

# Logging functions
log_error() {
    local code="$1"
    local path="$2"
    local message="$3"
    echo -e "${RED}ERROR [$code] $path: $message${NC}"
    # GitHub Actions annotation
    if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
        echo "::error file=$path::[$code] $message"
    fi
    ((ERRORS++))
}

log_warning() {
    local code="$1"
    local path="$2"
    local message="$3"
    echo -e "${YELLOW}WARN [$code] $path: $message${NC}"
    if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
        echo "::warning file=$path::[$code] $message"
    fi
    ((WARNINGS++))
}

log_success() {
    local path="$1"
    echo -e "${GREEN}PASS $path${NC}"
}

# Check if required tools are installed
check_dependencies() {
    if ! command -v yq &> /dev/null; then
        echo "Error: yq is required but not installed."
        echo "Install with: brew install yq (macOS) or download from https://github.com/mikefarah/yq"
        exit 1
    fi
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed."
        echo "Install with: brew install jq (macOS) or apt-get install jq (Linux)"
        exit 1
    fi
}

# Validate YAML syntax
validate_yaml_syntax() {
    local manifest="$1"
    local yaml_error
    yaml_error=$(yq eval '.' "$manifest" 2>&1)
    if [[ $? -ne 0 ]]; then
        log_error "E101" "$manifest" "Invalid YAML syntax. Parser error: ${yaml_error%%$'\n'*}"
        return 1
    fi
    return 0
}

# Validate required fields exist
validate_required_fields() {
    local manifest="$1"
    local missing=()

    for field in name version description author type; do
        local value
        value=$(yq eval ".$field // \"\"" "$manifest" 2>/dev/null)
        if [[ -z "$value" || "$value" == "null" ]]; then
            missing+=("$field")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "E102" "$manifest" "Missing required fields: ${missing[*]}. All packages must have: name (@author/pkg), version (semver), description, author, type (skill|rules|mcp)"
        return 1
    fi
    return 0
}

# Validate semver format
validate_semver() {
    local manifest="$1"
    local version
    version=$(yq eval '.version // ""' "$manifest" 2>/dev/null)

    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?(\+[a-zA-Z0-9.]+)?$ ]]; then
        log_error "E104" "$manifest" "Invalid semver '$version' (expected X.Y.Z format)"
        return 1
    fi
    return 0
}

# Validate package type
validate_package_type() {
    local manifest="$1"
    local pkg_type
    pkg_type=$(yq eval '.type // ""' "$manifest" 2>/dev/null)

    if [[ ! "$pkg_type" =~ ^($VALID_TYPES)$ ]]; then
        log_error "E105" "$manifest" "Invalid type '$pkg_type' (expected: skill, rules, or mcp)"
        return 1
    fi
    return 0
}

# Validate type-specific fields
validate_type_specific() {
    local manifest="$1"
    local pkg_type
    pkg_type=$(yq eval '.type // ""' "$manifest" 2>/dev/null)

    case "$pkg_type" in
        skill)
            local cmd desc
            cmd=$(yq eval '.skill.command // ""' "$manifest" 2>/dev/null)
            desc=$(yq eval '.skill.description // ""' "$manifest" 2>/dev/null)
            if [[ -z "$cmd" || "$cmd" == "null" ]]; then
                log_error "E107" "$manifest" "Skill package missing 'skill.command'. Add: skill: { command: '/your-command', description: '...' }"
                return 1
            fi
            if [[ ! "$cmd" =~ ^/[a-zA-Z0-9_-]+$ ]]; then
                log_error "E107" "$manifest" "Invalid skill command '$cmd'. Must be a slash command like '/my-skill' (alphanumeric, hyphens, underscores only)"
                return 1
            fi
            if [[ -z "$desc" || "$desc" == "null" ]]; then
                log_error "E107" "$manifest" "Skill package missing 'skill.description'. Add a brief description of what the command does"
                return 1
            fi
            ;;
        rules)
            local glob files
            glob=$(yq eval '.rules.glob // ""' "$manifest" 2>/dev/null)
            files=$(yq eval '.rules.files | length' "$manifest" 2>/dev/null)
            if [[ -z "$glob" || "$glob" == "null" ]]; then
                log_error "E107" "$manifest" "Rules package missing 'rules.glob'. Add: rules: { glob: '*.md', files: ['file1.md', 'file2.md'] }"
                return 1
            fi
            if [[ "$files" -eq 0 ]]; then
                log_error "E107" "$manifest" "Rules package missing 'rules.files' array. List all rule files that should be included"
                return 1
            fi
            ;;
        mcp)
            local cmd
            cmd=$(yq eval '.mcp.command // ""' "$manifest" 2>/dev/null)
            if [[ -z "$cmd" || "$cmd" == "null" ]]; then
                log_error "E107" "$manifest" "MCP package missing 'mcp.command'. Add: mcp: { command: 'npx', args: ['package-name'] }. Allowed commands: npx, node, python, uvx, docker"
                return 1
            fi
            ;;
    esac
    return 0
}

# Validate package name matches folder path
validate_name_matches_path() {
    local manifest="$1"
    local pkg_dir="$2"

    local name pkg_type
    name=$(yq eval '.name // ""' "$manifest" 2>/dev/null)
    pkg_type=$(yq eval '.type // ""' "$manifest" 2>/dev/null)

    # Extract author and package name from @author/package format
    if [[ ! "$name" =~ ^@([a-zA-Z0-9_-]+)/([a-zA-Z0-9_-]+)$ ]]; then
        log_error "E204" "$manifest" "Invalid name format '$name' (expected @author/package-name)"
        return 1
    fi

    local author="${BASH_REMATCH[1]}"
    local pkg_name="${BASH_REMATCH[2]}"

    # Construct expected path (type -> directory name)
    # skill -> skills, rules -> rules, mcp -> mcp
    local type_dir
    case "$pkg_type" in
        skill) type_dir="skills" ;;
        rules) type_dir="rules" ;;
        mcp)   type_dir="mcp" ;;
        *)     type_dir="${pkg_type}s" ;;
    esac
    local expected_path="packages/${type_dir}/${author}/${pkg_name}"

    # Get relative path from root
    local actual_path="${pkg_dir#$ROOT_DIR/}"

    if [[ "$actual_path" != "$expected_path" ]]; then
        log_error "E200" "$manifest" "Name '$name' doesn't match path (expected: $expected_path, actual: $actual_path)"
        return 1
    fi
    return 0
}

# Check for path traversal attempts
validate_no_path_traversal() {
    local pkg_dir="$1"

    while IFS= read -r -d '' file; do
        local relative_path="${file#$pkg_dir/}"
        if [[ "$relative_path" == *".."* ]]; then
            log_error "E201" "$pkg_dir" "SECURITY: Path traversal detected in '$relative_path'. Files with '..' in the path are not allowed as they could access files outside the package directory"
            return 1
        fi
    done < <(find "$pkg_dir" -type f -print0 2>/dev/null)
    return 0
}

# Check for hidden files
validate_no_hidden_files() {
    local pkg_dir="$1"

    while IFS= read -r -d '' file; do
        local basename
        basename=$(basename "$file")
        if [[ "$basename" == .* && "$basename" != ".gitkeep" ]]; then
            log_error "E202" "$pkg_dir" "SECURITY: Hidden file detected: '$basename'. Hidden files (starting with .) are not allowed in packages to prevent accidental inclusion of sensitive files like .env or .secret"
            return 1
        fi
    done < <(find "$pkg_dir" -type f -name ".*" -print0 2>/dev/null)
    return 0
}

# Check for allowed file types only
validate_allowed_filetypes() {
    local pkg_dir="$1"

    while IFS= read -r -d '' file; do
        local basename ext
        basename=$(basename "$file")
        ext="${basename##*.}"

        # Skip files without extension (like cpm.yaml is fine)
        if [[ "$basename" == "$ext" ]]; then
            continue
        fi

        ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
        if [[ ! "$ext" =~ ^($ALLOWED_EXTENSIONS)$ ]]; then
            log_error "E304" "$pkg_dir" "SECURITY: Disallowed file type '.$ext' in file '$basename'. Only these extensions are allowed: .md, .yaml, .yml, .json, .mdc. Executable files (.sh, .exe, .py, etc.) are not permitted"
            return 1
        fi
    done < <(find "$pkg_dir" -type f -print0 2>/dev/null)
    return 0
}

# Validate MCP security
validate_mcp_security() {
    local manifest="$1"
    local pkg_type
    pkg_type=$(yq eval '.type // ""' "$manifest" 2>/dev/null)

    # Only validate MCP packages
    if [[ "$pkg_type" != "mcp" ]]; then
        return 0
    fi

    # Check command is on allowlist
    local cmd
    cmd=$(yq eval '.mcp.command // ""' "$manifest" 2>/dev/null)
    if [[ ! "$cmd" =~ ^($MCP_ALLOWED_COMMANDS)$ ]]; then
        log_error "E300" "$manifest" "Command '$cmd' not in allowlist (allowed: npx, node, python, uvx, docker)"
        return 1
    fi

    # Check args for shell metacharacters
    local args
    args=$(yq eval '.mcp.args[]? // ""' "$manifest" 2>/dev/null | tr '\n' ' ')
    if [[ -n "$args" ]]; then
        # Check for dangerous patterns
        if echo "$args" | grep -qE '[;|&`$()]|&&|\|\|'; then
            log_error "E301" "$manifest" "SECURITY: Shell metacharacters detected in mcp.args. Characters like ; | & \` \$() && || are not allowed as they enable command injection attacks"
            return 1
        fi

        # Check for suspicious flags
        if echo "$args" | grep -qE -- '--eval|-e |--exec|^-c '; then
            log_error "E302" "$manifest" "SECURITY: Suspicious code execution flags detected in mcp.args. Flags like --eval, -e, --exec, -c allow arbitrary code execution and are not permitted"
            return 1
        fi

        # Check for network commands
        if echo "$args" | grep -qE 'curl |wget |nc |netcat |telnet '; then
            log_error "E303" "$manifest" "SECURITY: Network commands detected in mcp.args. Commands like curl, wget, nc, netcat, telnet are not allowed as they could exfiltrate data or download malicious payloads"
            return 1
        fi
    fi

    # Check env keys for valid format and values for shell metacharacters
    local env_keys
    env_keys=$(yq eval '.mcp.env // {} | keys | .[]' "$manifest" 2>/dev/null)
    if [[ -n "$env_keys" ]]; then
        while IFS= read -r key; do
            # Env var names must be uppercase alphanumeric with underscores
            if [[ ! "$key" =~ ^[A-Z][A-Z0-9_]*$ ]]; then
                log_error "E305" "$manifest" "SECURITY: Invalid env var name '$key'. Must be uppercase alphanumeric with underscores (e.g. DATABASE_URL)"
                return 1
            fi
            local val
            val=$(yq eval ".mcp.env.\"$key\" // \"\"" "$manifest" 2>/dev/null)
            if echo "$val" | grep -qE '[;|&`$()]|&&|\|\|'; then
                log_error "E306" "$manifest" "SECURITY: Shell metacharacters detected in env var '$key'. Characters like ; | & \` \$() && || are not allowed"
                return 1
            fi
        done <<< "$env_keys"
    fi
    return 0
}

# Validate namespace usage
validate_namespace() {
    local manifest="$1"
    local name
    name=$(yq eval '.name // ""' "$manifest" 2>/dev/null)

    # Extract namespace from @namespace/package
    if [[ "$name" =~ ^@([a-zA-Z0-9_-]+)/ ]]; then
        local namespace="${BASH_REMATCH[1]}"
        if [[ "$namespace" =~ ^($MAINTAINER_NAMESPACES)$ ]]; then
            log_warning "E203" "$manifest" "Using reserved namespace '@$namespace' - requires maintainer approval"
        fi
    fi
    return 0
}

# Validate package exists in registry
validate_registry_entry() {
    local manifest="$1"
    local name
    name=$(yq eval '.name // ""' "$manifest" 2>/dev/null)

    if [[ ! -f "$REGISTRY_FILE" ]]; then
        log_error "E400" "$manifest" "Registry file not found at $REGISTRY_FILE. The registry.json file is required for package discovery"
        return 1
    fi

    local entry
    entry=$(jq -e --arg name "$name" '.packages[] | select(.name == $name)' "$REGISTRY_FILE" 2>/dev/null)
    if [[ -z "$entry" ]]; then
        log_error "E400" "$manifest" "Package '$name' not found in registry.json. Add an entry with: { \"name\": \"$name\", \"path\": \"<type>/<author>/<pkg>\", \"version\": \"X.Y.Z\", \"description\": \"...\", \"author\": \"...\" }"
        return 1
    fi
    return 0
}

# Validate version matches registry
validate_registry_version() {
    local manifest="$1"
    local name version
    name=$(yq eval '.name // ""' "$manifest" 2>/dev/null)
    version=$(yq eval '.version // ""' "$manifest" 2>/dev/null)

    if [[ ! -f "$REGISTRY_FILE" ]]; then
        return 0  # Already reported in validate_registry_entry
    fi

    local registry_version
    registry_version=$(jq -r --arg name "$name" '.packages[] | select(.name == $name) | .version // ""' "$REGISTRY_FILE" 2>/dev/null)

    if [[ -n "$registry_version" && "$registry_version" != "$version" ]]; then
        log_error "E402" "$manifest" "Version mismatch: cpm.yaml has '$version' but registry.json has '$registry_version'. Update both files to use the same version"
        return 1
    fi
    return 0
}

# Validate a single package
validate_package() {
    local pkg_path="$1"
    local pkg_dir="$PACKAGES_DIR/$pkg_path"
    local manifest="$pkg_dir/cpm.yaml"

    echo "Validating: $pkg_path"

    # Check cpm.yaml exists
    if [[ ! -f "$manifest" ]]; then
        log_error "E100" "$pkg_dir" "Missing cpm.yaml manifest file. Create a cpm.yaml with required fields: name, version, description, author, type"
        return 1
    fi

    local failed=0

    # Run all validations
    validate_yaml_syntax "$manifest" || failed=1

    # Only continue if YAML is valid
    if [[ $failed -eq 0 ]]; then
        validate_required_fields "$manifest" || failed=1
        validate_semver "$manifest" || failed=1
        validate_package_type "$manifest" || failed=1
        validate_type_specific "$manifest" || failed=1
        validate_name_matches_path "$manifest" "$pkg_dir" || failed=1
        validate_no_path_traversal "$pkg_dir" || failed=1
        validate_no_hidden_files "$pkg_dir" || failed=1
        validate_allowed_filetypes "$pkg_dir" || failed=1
        validate_mcp_security "$manifest" || failed=1
        validate_namespace "$manifest"
        validate_registry_entry "$manifest" || failed=1
        validate_registry_version "$manifest" || failed=1
    fi

    if [[ $failed -eq 0 ]]; then
        log_success "$pkg_path"
    fi

    return $failed
}

# Validate all packages or specific ones
main() {
    check_dependencies

    local packages_to_validate=()

    if [[ $# -gt 0 && -n "$1" ]]; then
        # Validate specific packages (from command line or changed files)
        # Input can be newline-separated or space-separated
        local input="$1"
        # Convert spaces to newlines if input appears to be space-separated (no newlines)
        if [[ "$input" != *$'\n'* && "$input" == *" "* ]]; then
            input=$(echo "$input" | tr ' ' '\n')
        fi
        while IFS= read -r pkg; do
            # Trim whitespace
            pkg=$(echo "$pkg" | xargs)
            [[ -n "$pkg" ]] && packages_to_validate+=("$pkg")
        done <<< "$input"
    else
        # Validate all packages
        while IFS= read -r dir; do
            local relative_path="${dir#$PACKAGES_DIR/}"
            packages_to_validate+=("$relative_path")
        done < <(find "$PACKAGES_DIR" -name "cpm.yaml" -exec dirname {} \; 2>/dev/null | sort)
    fi

    if [[ ${#packages_to_validate[@]} -eq 0 ]]; then
        echo "No packages to validate"
        exit 0
    fi

    echo "================================"
    echo "CPM Package Validation"
    echo "================================"
    echo "Packages to validate: ${#packages_to_validate[@]}"
    echo ""

    local failed_packages=0
    for pkg in "${packages_to_validate[@]}"; do
        if ! validate_package "$pkg"; then
            ((failed_packages++))
        fi
        echo ""
    done

    echo "================================"
    echo "Summary"
    echo "================================"
    echo "Total packages: ${#packages_to_validate[@]}"
    echo "Passed: $((${#packages_to_validate[@]} - failed_packages))"
    echo "Failed: $failed_packages"
    echo "Errors: $ERRORS"
    echo "Warnings: $WARNINGS"

    if [[ $ERRORS -gt 0 ]]; then
        exit 1
    fi
    exit 0
}

main "$@"
