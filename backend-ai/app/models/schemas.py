from pydantic import BaseModel, Field, field_validator
from typing import Any


class FraudCheckRequest(BaseModel):
    amount: float = Field(gt=0)
    merchant: str | None = Field(None, max_length=200)
    category: str | None = Field(None, max_length=100)
    location: str | None = Field(None, max_length=200)
    device_id: str | None = None
    receiver: str | None = Field(None, max_length=200)

    @field_validator("amount")
    @classmethod
    def validate_amount(cls, v: float) -> float:
        if v <= 0:
            raise ValueError("amount must be positive")
        return round(v, 2)


class FraudCheckResponse(BaseModel):
    risk_score: float = Field(ge=0, le=100)
    risk_level: str  # low, medium, high, critical
    signals: list[str] = []
    decision: str  # allow, freeze, block
    message: str = ""


class CoachRequest(BaseModel):
    question: str = Field(min_length=1, max_length=2000)
    context: dict[str, Any] | None = None


class CoachResponse(BaseModel):
    answer: str
    suggestions: list[str] = []


class PatternAnalysisRequest(BaseModel):
    force: bool = False


class PatternAnalysisResponse(BaseModel):
    patterns_detected: int
    patterns: list[dict[str, Any]] = []


class BusinessAdviceRequest(BaseModel):
    question: str = Field(min_length=1, max_length=2000)
    business_data: dict[str, Any] | None = None


class BusinessAdviceResponse(BaseModel):
    answer: str
    metrics: dict[str, Any] = {}
