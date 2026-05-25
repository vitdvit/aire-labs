# Lab-7 — Research: "Vin's Questions"

Дослідження та оцінка власного сетапу AI-інфраструктури на основі питань від реального замовника.

## Питання

1. How could we handle 'agent got stuck' scenarios?
2. Any automatic timeout/circuit breaker patterns coming out from this framework?
3. How does kgateway handle model failover?
4. Can we automatically switch from OpenAI to Claude to local model?
5. Could we seamlessly handle the response formats from these providers?
6. Can we version the agents built from kagent?
7. Any blue/green or canary deployment patterns for agents?
8. What's the fastmcp-python framework mentioned?
9. Is it the easiest path to MCP?
10. About finops: how much control I can have?
11. Token level / per agent level?
12. Can I implement custom cost controls?
13. Per-agent budgets or depth of Token limits?
14. vLLM suitable for agents with many back and forth tool calls, or is it better for single shot inference?
15. llm-d's scheduler — helps when agent makes 15 LLM calls?

## Стек

| Компонент | Роль |
|-----------|------|
| kgateway (agentgateway) | LLM routing, failover, rate limiting |
| kagent | Agent orchestration on Kubernetes |
| Gemini gemini-2.0-flash | Primary LLM provider |
| LiteLLM | Local LLM proxy / fallback |
| FastMCP | MCP server framework |
| Qdrant | Vector database |
| Arize Phoenix | Observability / tracing |
| Flux CD | GitOps |
