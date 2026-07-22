from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.core.supabase import get_supabase

_bearer = HTTPBearer(auto_error=False)


async def get_current_user(credentials: HTTPAuthorizationCredentials | None = Depends(_bearer)) -> str:
    if credentials is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing Authorization header")

    token = credentials.credentials
    if not token:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

    try:
        supabase = get_supabase()
        user = supabase.auth.get_user(token)
        if user and user.user:
            return user.user.id
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=f"Token verification failed: {e}")

    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired token")
