from fastapi import APIRouter, Depends, HTTPException
from app.models.schemas import CoachRequest, CoachResponse
from app.services.financial_coach import FinancialCoach
from app.core.auth import get_current_user
from app.core.logger import setup_logger

router = APIRouter()
logger = setup_logger("coach_route")


@router.post("/ask", response_model=CoachResponse)
async def ask_coach(request: CoachRequest, user_id: str = Depends(get_current_user)):
    try:
        coach = FinancialCoach()
        result = await coach.answer(request, user_id)
        return result
    except Exception as e:
        logger.error(f"Coach failed for user {user_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))
