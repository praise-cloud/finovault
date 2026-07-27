import pytest
import os
import sys


def test_settings_validates_required_vars():
    """Settings.validate() should exit when SUPABASE_URL is missing."""
    from app.core.config import Settings
    s = Settings()
    s.SUPABASE_URL = ""
    s.SUPABASE_SERVICE_KEY = ""
    with pytest.raises(SystemExit):
        s.validate()


def test_settings_cors_origins_default():
    from app.core.config import settings
    origins = settings.cors_origins
    assert isinstance(origins, list)
    assert len(origins) >= 4
    assert "http://localhost:4000" in origins


def test_log_level_default():
    from app.core.config import settings
    assert settings.LOG_LEVEL in ("INFO", "DEBUG", "WARNING", "ERROR")
