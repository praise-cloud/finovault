from supabase import create_client, Client

# Note: The supabase-py library primarily uses sync clients.
# For async operations, we use the sync client. The blocking calls
# can be run in executor threads if needed.
# Future migration: use gotrue-py async when available.

from app.core.config import settings

_client: Client | None = None


def get_supabase() -> Client:
    global _client
    if _client is None:
        _client = create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_KEY)
    return _client
