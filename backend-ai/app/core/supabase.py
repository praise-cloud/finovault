import asyncio
from typing import Any
from supabase import create_client, Client

from app.core.config import settings

_client: Client | None = None


def get_supabase() -> Client:
    global _client
    if _client is None:
        _client = create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_KEY)
    return _client


async def async_execute(query_builder: Any) -> Any:
    """Run a sync supabase query in a thread pool to avoid blocking the event loop."""
    return await asyncio.to_thread(query_builder.execute)
