"""
A2A Agent — implements Agent Card + task execution endpoint.
Spec: https://a2a-protocol.org
"""
import datetime
import os

import uvicorn
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

app = FastAPI(title="AIRe DevOps A2A Agent", version="1.0.0")

AGENT_CARD = {
    "name": "AIRe DevOps Agent",
    "description": "A DevOps assistant agent that answers infrastructure questions.",
    "version": "1.0.0",
    "url": os.getenv("AGENT_BASE_URL", "http://localhost:8001"),
    "capabilities": {
        "streaming": False,
        "pushNotifications": False,
        "stateTransitionHistory": False,
    },
    "defaultInputModes": ["text/plain"],
    "defaultOutputModes": ["text/plain"],
    "skills": [
        {
            "id": "devops-info",
            "name": "DevOps Info",
            "description": "Answers basic DevOps and infrastructure questions.",
            "tags": ["devops", "kubernetes", "infrastructure"],
            "examples": ["What time is it?", "Tell me about this agent."],
        }
    ],
}


@app.get("/.well-known/agent.json")
async def agent_card():
    return JSONResponse(content=AGENT_CARD)


@app.post("/tasks/send")
async def send_task(request: Request):
    body = await request.json()
    task_id = body.get("id", "unknown")
    message = ""
    parts = body.get("message", {}).get("parts", [])
    for part in parts:
        if part.get("type") == "text":
            message = part.get("text", "")
            break

    reply_text = f"[{datetime.datetime.utcnow().isoformat()}] Received: {message}"

    return {
        "id": task_id,
        "status": {"state": "completed"},
        "artifacts": [
            {
                "parts": [{"type": "text", "text": reply_text}],
                "index": 0,
            }
        ],
    }


if __name__ == "__main__":
    port = int(os.getenv("PORT", "8001"))
    uvicorn.run(app, host="0.0.0.0", port=port)
