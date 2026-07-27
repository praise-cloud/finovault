from fastapi import Request
from slowapi import Limiter
from slowapi.util import get_remote_address


def _ip_key(request: Request) -> str:
    forwarded = request.headers.get("X-Forwarded-For")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return get_remote_address(request)


limiter = Limiter(key_func=_ip_key, default_limits=["60/minute"])
