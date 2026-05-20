import datetime
import os

import uvicorn
from mcp.server.fastmcp import FastMCP

PORT = int(os.getenv("PORT", "8000"))
mcp = FastMCP("devops-tools", host="0.0.0.0", port=PORT)


@mcp.tool()
def get_time() -> str:
    """Return current UTC time."""
    return datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")


@mcp.tool()
def echo(message: str) -> str:
    """Echo a message back to the caller."""
    return f"Echo: {message}"


@mcp.tool()
def get_env_info() -> dict:
    """Return non-sensitive runtime environment information."""
    return {
        "hostname": os.getenv("HOSTNAME", "unknown"),
        "namespace": os.getenv("POD_NAMESPACE", "unknown"),
        "pod": os.getenv("POD_NAME", "unknown"),
        "server": "devops-tools-mcp",
        "version": "1.0.0",
    }


@mcp.tool()
def list_tools() -> list:
    """List all available MCP tools."""
    return ["get_time", "echo", "get_env_info", "list_tools"]


if __name__ == "__main__":
    mcp.run(transport="streamable-http")
