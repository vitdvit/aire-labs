# Lab-7 — Answers to Vin's Questions

## 1–2. Agent stuck scenarios & timeout/circuit breaker patterns

agentgateway обробляє обидва на рівні шлюзу: таймаут запиту вбиває завислий агентний цикл до того як він накопичується, а circuit breaker відключає трафік до деградованого бекенду після N послідовних помилок і відновлює його автоматично. На рівні Kubernetes — liveness і readiness probes на kagent-подах тригерять рестарт kubelet без ручного втручання. Маємо два незалежні шари: шлюз обриває запит швидко, k8s лікує под.

## 3. How does kgateway handle model failover?

kgateway підтримує пріоритетні групи бекендів. Визначаємо primary (Gemini) і fallback (локальний LiteLLM) через `failoverPriority` у `Backend` CR. При 5xx або таймауті маршрутизація перемикається на наступний бекенд прозоро для клієнта — жодних змін у коді агента не потрібно.

## 4. Can we automatically switch from OpenAI to Claude to local model?

Так, через backend priority в kgateway. Ланцюжок: OpenAI → Claude → local LiteLLM — failover відбувається автоматично при помилці без змін у коді агента. Єдине що змінюється — конфігурація `Backend` CR у Kubernetes.

## 5. Could we seamlessly handle the response formats from these providers?

kgateway нормалізує відповіді до OpenAI-сумісного формату (chat completions API). Kagent і MCP-сервери взаємодіють виключно з kgateway, тому зміна провайдера не вимагає адаптації коду агента — формат завжди однаковий.

## 6. Can we version the agents built from kagent?

Так. Kagent зберігає агентів як Kubernetes CRD (`Agent` resource). Версіонування — через GitOps (Flux CD): кожна зміна конфігурації агента це git commit з повним audit trail і можливістю rollback через `git revert` або `flux reconcile`.

## 7. Any blue/green or canary deployment patterns for agents?

Стандартні Kubernetes паттерни повністю застосовні. Blue/green — два Deployment з перемиканням Service selector. Canary — HTTPRoute weights у kgateway (наприклад, 90% stable / 10% canary). Flux CD автоматизує rollout і rollback. Для агентів це особливо зручно бо конфіг агента декларативний.

## 8. What's the fastmcp-python framework?

FastMCP — Python-бібліотека з декораторним API схожим на FastAPI для швидкого створення MCP-серверів. Функція + `@mcp.tool()` → готовий MCP-інструмент без бойлерплейту. Використовуємо для власного `devops-tools-mcp` сервера.

## 9. Is it the easiest path to MCP?

Так, FastMCP — найшвидший шлях. Визначаєш функцію, додаєш декоратор, пакуєш у Docker, деплоїш як Kubernetes Deployment. Порівняно з нативним MCP SDK — у 3-4 рази менше коду і менше шансів зробити помилку в протоколі.

## 10. About finops: how much control I can have?

kgateway підтримує rate limiting і token budgets на рівні HTTPRoute Policy. Контроль є на рівні маршруту, агента і користувача — все декларативно через Kubernetes CR. Arize Phoenix агрегує реальні витрати токенів для алертингу і аналітики.

## 11. Token level / per agent level?

Так, обидва рівні доступні. На рівні токенів — через provider-side quotas (Gemini/OpenAI) і метрики з Phoenix. На рівні агента — окремий HTTPRoute per agent з власним rate limit policy, тому кожен агент має незалежний ліміт.

## 12. Can I implement custom cost controls?

Так, через External Authorization (ext-authz) у kgateway — власний сервіс отримує кожен запит до відправки до LLM, перевіряє поточні витрати і може заблокувати запит при перевищенні бюджету. Логіку контролю пишеш сам, інтеграція стандартна.

## 13. Per-agent budgets or depth of Token limits?

Обидва варіанти: per-agent budget через окремий HTTPRoute з rate limit policy, token depth limit через `max_tokens` параметр на рівні запиту або через ext-authz який відстежує накопичені витрати per agent за проміжок часу.

## 14. vLLM for agents with many tool calls vs single shot inference?

vLLM оптимізований під throughput, не latency — це перевага для single-shot inference. Для агентів з 10-15+ sequential tool calls latency кожного кроку критичніша ніж throughput. В таких сценаріях краще тюнити `--max-num-seqs` під невеликий batch або використовувати continuous batching з aggressive preemption. У нашому сетапі для агентних сценаріїв routing через LiteLLM дозволяє задавати окремі параметри per request type.

## 15. llm-d scheduler — does it help when agent makes 15 LLM calls?

Так, і суттєво. llm-d scheduler вирішує проблему KV-cache locality — направляє sequential запити в межах однієї сесії до того ж GPU де вже є кешований контекст. Для агента з 15 calls це знижує latency на кожному кроці (менше KV-cache misses і prefill overhead). Наш поточний сетап без llm-d, але для heavy agent workloads на локальному кластері це логічний наступний крок.
