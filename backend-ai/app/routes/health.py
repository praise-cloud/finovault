from fastapi import APIRouter
from app.core.supabase import async_execute, get_supabase

router = APIRouter()


@router.get("/health")
async def health_check():
    db_status = "ok"
    try:
        supabase = get_supabase()
        await async_execute(supabase.table("profiles").select("id").limit(1))
    except Exception:
        db_status = "error"

    return {
        "status": "healthy",
        "service": "finovault-ai",
        "database": db_status,
    }
