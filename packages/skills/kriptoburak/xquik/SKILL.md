---
name: xquik
description: Use Xquik to search public X data, monitor activity, publish from connected accounts, and automate workflows through REST API, webhooks, and MCP.
---

# Xquik

Xquik is an independent third-party service. Not affiliated with X Corp. "Twitter" and "X" are trademarks of X Corp.

Use Xquik to search public X data, monitor activity, publish from connected accounts, and automate workflows.

## Connect Through MCP

1. Add the Streamable HTTP endpoint: `https://xquik.com/mcp`.
2. Complete the OAuth 2.1 flow opened by the MCP client.
3. Call `explore` to find the smallest relevant operation.
4. Call `xquik` to run the selected operation.

MCP clients discover authorization metadata automatically. API-key fallback is client-specific. ChatGPT custom apps require OAuth and cannot present custom API keys.

## Use the REST API

1. Read the [API guide](https://docs.xquik.com/api-reference/overview).
2. Read the [OpenAPI schema](https://xquik.com/openapi.json).
3. Send an Xquik API key through the `x-api-key` header.
4. Follow `has_more` and `next_cursor` for paginated reads.
5. Respect structured errors and `retry_after` values.

Never ask for, echo, log, or store secret values in prompts, examples, or tool arguments.

## Workflow

1. Confirm whether the request is read-only or changes account state.
2. Discover the relevant operation through MCP or the OpenAPI schema.
3. Use the smallest operation that satisfies the request.
4. Request explicit approval immediately before account-changing actions.
5. Report structured errors without silently changing routes or authentication.

## Discovery

- Repository: https://github.com/Xquik-dev/x-twitter-scraper
- MCP guide: https://docs.xquik.com/mcp/overview
- OAuth guide: https://docs.xquik.com/oauth/overview
- Authentication instructions: https://xquik.com/auth.md
- MCP manifest: https://xquik.com/.well-known/mcp.json
- Agent skill: https://xquik.com/.well-known/agent-skills/xquik/SKILL.md
