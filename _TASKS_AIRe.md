# _TASKS_AIRe

Lab-1: Розгортання Basic Agentic Infrastructure:

Початківці:
1. Встановити agentgateway https://agentgateway.dev/docs/standalone/latest/deployment/binary/
2. Обрати llm провайдера це наш джемені ключ https://agentgateway.dev/docs/standalone/latest/llm/providers/
3. Налаштувати config.yaml https://agentgateway.dev/docs/standalone/latest/tutorials/llm-gateway/
4. Запустити gateway та отримати доступ через UI http://localhost:15000/ui/
5. Перевірити доступ до llm та ознайомитися з фундаментальними можливостями Backends та Policy

Досвідчені
1. Виконати завдання початківців але як helm deployment в Kubernetes кластері
2. Налаштувати Secrets та ConfigMap для API ключів та конфігурації
3. Розгорнути kagent https://kagent.dev/docs/kagent/getting-started/quickstart
4. Налаштувати маршрут моделі через agentgateway
5. Перевірити роботу будь-якого вбудованого агента

Макс:
1. Виконати завдання досвідчених але з gateway API https://agentgateway.dev/docs/kubernetes/main/about/gateway-api/

Lab-2
Початківці (завдання на сертифікат)
1. Розгорнути abox (https://github.com/den-vasyliev/abox)
2. Отримати доступи до UI Flux, Kagent, agentgateway
3. Підключити модель, створити declarative MCP tool server та агента в Kagent

https://github.com/den-vasyliev/abox
Рекомендовані вимоги до системи: 4-core • 16GB RAM • 32GB*



Досвідчені
1. Завдання початківців але розгортання MCP сервера та агента за допомогою GitOps

Lab-3
Початківці
Research:
1. Які реальні технічні та бізнесові кейси можуть бути імплементовані з MCP Sampling/Elicitation/MCP Apps (на вибір)

Development:
1. Ознайомитися з kmcp https://www.solo.io/blog/introducing-kmcp, розробити та задеплоїти в abox власний сервер
2. Ознайомитися з google-agents-cli https://google.github.io/agents-cli/, розробити та задеплоїти в abox власний агент з MCP власного сервера
3. Ознайомитися з використанням npx @modelcontextprotocol/inspector@0.21.1 та agents-cli playground для власного MCP серверу та agent запущеного у вашій інфраструктурі

https://github.com/den-vasyliev/mastering-k8s
https://github.com/den-vasyliev/k8s-controller-tutorial

Досвідчені
1. Завдання початківців
2. Development: Реалізувати свій MCP Apps кейс

Макс
1. Завдання досвідчених
2. Development: Реалізувати свій MCP Sampling/Elicitation кейс

https://www.anthropic.com/engineering/building-effective-agents

https://www.deeplearning.ai/courses/agentic-ai

https://a2a-protocol.org/latest/topics/enterprise-ready/

https://modelcontextprotocol.io/specification/2025-11-25



Voiceover агент для тестів можна взяти тут: https://github.com/den-vasyliev/voiceover

src - перша версія

adk_agent - версія згенерована google-agents-cli скілами через CC

Lab-4
Початківці (завдання на сертифікат)
Research:
1. Ознайомитися із специфікацією a2a https://a2a-protocol.org
   Development:
2. Реалізувати власного агента (будь який фреймовк) з Agent Card та отримати карту агента за Well-Known URI
   Infrastructure:
3. Розгорнути Inventory (https://github.com/den-vasyliev/agentregistry-inventory) на abox (або будь-яку альтернативу, можна на власному середовищі) та отримати перелік AI ресурсів в кластері
4. Infrastructure: розгорнути MCPG (https://github.com/techwithhuz/mcp-security-governance) у власній AI Інфраструктурі (або аналогічний інструмент)
5. Розгорнути в abox (на власному середовищі) векторну базу даних qdrant https://github.com/qdrant/qdrant-helm

Досвідчені
1. Завдання початківців
2. Development: Реалізувати a2a task комунікацію між двома агентами

Макс
1. Завдання досвідчених
2. Development: Реалізувати a2a team з власним агентом та агентами kagent (на власний вибір) і поставьте одне завдання на виконання різними агентами комплексно

Lab-5
Початківці:
1. Agent Sandbox: ознайомитися з прикладами https://agent-sandbox.sigs.k8s.io/docs/use-cases/examples/
2. Реалізувати будь-який варіант або рекомендований: https://agent-sandbox.sigs.k8s.io/docs/use-cases/examples/network-policies/
3. Ознайомитися з Tracing and Evaluating та виконати Colab LangChain Application https://colab.research.google.com/github/Arize-ai/phoenix/blob/main/tutorials/tracing/langchain_tracing_tutorial.ipynb

Досвідчені:
1. Розгорнути у abox Arize Phoenix https://arize.com/docs/phoenix/self-hosting/deployment-options/kubernetes-helm
2. Реалізувати збір телеметрії у Agent Sandbox https://agent-sandbox.sigs.k8s.io/docs/sandbox/metrics/
3. Інструментувати Tracing для свого MCP серверу та отримати траси у Phoenix https://arize.com/docs/phoenix/integrations/python/mcp-tracing

Макс:
1. Налаштувати збір телеметрії на agentgateway у Phoenix https://agentgateway.dev/docs/kubernetes/latest/tutorials/telemetry/
2. Ознайомитися з управлінням Agent Sandbox за допомогою SDK https://agent-sandbox.sigs.k8s.io/docs/use-cases/examples/code-interpreter-agent-on-adk/

Додаткові завдання (при розгорнутому abox - виконується декількома маніфестами):
*API key case on agentgateway https://agentgateway.dev/docs/kubernetes/latest/security/apikey/
**Guardrails case on agentgateway https://agentgateway.dev/docs/kubernetes/latest/llm/guardrails/webhook/guardrails/



## Статус

| Символ | Значення |
|---|---|
| `[ ]` | TODO |
| `[~]` | In Progress |
| `[x]` | Done |

---

## Беклог

> Задачі будуть додані після визначення вимог.

---

## Виконано

<!-- Перенести сюди завершені задачі -->
