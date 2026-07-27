import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from fastapi import HTTPException, Request
from fastapi.security import HTTPAuthorizationCredentials


@pytest.mark.asyncio
async def test_get_current_user_with_api_key():
    """Service-to-service auth with X-Api-Key and X-User-Id should succeed."""
    from app.core.auth import get_current_user

    request = MagicMock(spec=Request)
    request.headers = {
        "X-Api-Key": "test-key",
        "X-User-Id": "user-123",
    }

    with patch("app.core.auth.settings") as mock_settings:
        mock_settings.AI_SERVICE_KEY = "test-key"
        result = await get_current_user(request, None)
        assert result == "user-123"


@pytest.mark.asyncio
async def test_get_current_user_missing_user_id_with_api_key():
    """X-Api-Key without X-User-Id should raise 401."""
    from app.core.auth import get_current_user

    request = MagicMock(spec=Request)
    request.headers = {"X-Api-Key": "test-key"}

    with patch("app.core.auth.settings") as mock_settings:
        mock_settings.AI_SERVICE_KEY = "test-key"
        with pytest.raises(HTTPException) as exc:
            await get_current_user(request, None)
        assert exc.value.status_code == 401


@pytest.mark.asyncio
async def test_get_current_user_no_auth():
    """No credentials at all should raise 401."""
    from app.core.auth import get_current_user

    request = MagicMock(spec=Request)
    request.headers = {}

    with patch("app.core.auth.settings") as mock_settings:
        mock_settings.AI_SERVICE_KEY = "test-key"
        with pytest.raises(HTTPException) as exc:
            await get_current_user(request, None)
        assert exc.value.status_code == 401


@pytest.mark.asyncio
async def test_get_current_user_invalid_jwt():
    """Invalid JWT should raise 401."""
    from app.core.auth import get_current_user

    request = MagicMock(spec=Request)
    request.headers = {}

    credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials="bad-token")

    with patch("app.core.auth.settings") as mock_settings, \
         patch("app.core.auth.asyncio.to_thread", new_callable=AsyncMock) as mock_to_thread:
        mock_settings.AI_SERVICE_KEY = "test-key"
        mock_to_thread.side_effect = Exception("Invalid token")

        with pytest.raises(HTTPException) as exc:
            await get_current_user(request, credentials)
        assert exc.value.status_code == 401
