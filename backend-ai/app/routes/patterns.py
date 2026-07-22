from fastapi import APIRouter, Depends, HTTPException
from app.models.schemas import PatternAnalysisRequest, PatternAnalysisResponse
from app.services.pattern_recognizer import PatternRecognizer
from app.core.auth import get_current_user
from app.core.logger import setup_logger

router = APIRouter()
logger = setup_logger("patterns_route")


@router.post("/analyze", response_model=PatternAnalysisResponse)
async def analyze_patterns(request: PatternAnalysisRequest, user_id: str = Depends(get_current_user)):
    try:
        recognizer = PatternRecognizer()
        result = await recognizer.analyze(request, user_id)
        return result
    except Exception as e:
        logger.error(f"Pattern analysis failed for user {user_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))
