from fastapi import APIRouter, HTTPException
from app.models.schemas import CoachRequest, CoachResponse
from app.services.financial_coach import FinancialCoach
from app.core.logger import setup_logger

router = APIRouter()
logger = setup_logger("coach_route")


@router.post("/ask", response_model=CoachResponse)
async def ask_coach(request: CoachRequest):
    try:
        coach = FinancialCoach()
        result = await coach.answer(request)
        return result
    except Exception as e:
        logger.error(f"Coach failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))
