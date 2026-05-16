import pytest

from app.core.config import settings
from app.db.model_schema_drift import ModelSchemaDriftReport
from app.services.startup_diagnostics_service import StartupDiagnosticsService
import app.services.startup_diagnostics_service as diagnostics_module


def test_schema_drift_component_reports_ready(monkeypatch):
    monkeypatch.setattr(settings, "ALLOW_START_WITHOUT_DB", False, raising=False)
    monkeypatch.setattr(
        diagnostics_module,
        "get_model_schema_drift_report",
        lambda emit_logs=False: ModelSchemaDriftReport(
            actionable_missing_tables=[],
            ignored_missing_tables=[],
            check_error=None,
        ),
    )

    component = StartupDiagnosticsService._schema_drift_component()
    assert component["status"] == "ready"
    assert component["required"] is True
    assert component["details"]["missing_table_count"] == 0


def test_schema_drift_component_reports_missing_tables(monkeypatch):
    monkeypatch.setattr(settings, "ALLOW_START_WITHOUT_DB", False, raising=False)
    monkeypatch.setattr(
        diagnostics_module,
        "get_model_schema_drift_report",
        lambda emit_logs=False: ModelSchemaDriftReport(
            actionable_missing_tables=["pricing_recommendations", "churn_predictions"],
            ignored_missing_tables=[],
            check_error=None,
        ),
    )

    component = StartupDiagnosticsService._schema_drift_component()
    assert component["status"] == "drifted"
    assert component["required"] is True
    assert component["details"]["missing_table_count"] == 2
    assert component["details"]["missing_tables"] == [
        "pricing_recommendations",
        "churn_predictions",
    ]


def test_enforce_required_dependencies_fails_on_schema_drift(monkeypatch):
    monkeypatch.setattr(settings, "STRICT_STARTUP_DEPENDENCY_CHECKS", True, raising=False)
    monkeypatch.setattr(settings, "ENVIRONMENT", "production", raising=False)
    monkeypatch.setattr(
        StartupDiagnosticsService,
        "collect_report",
        staticmethod(lambda: {"required_failures": ["schema_drift"]}),
    )

    with pytest.raises(RuntimeError, match="schema_drift"):
        StartupDiagnosticsService.enforce_required_dependencies()

