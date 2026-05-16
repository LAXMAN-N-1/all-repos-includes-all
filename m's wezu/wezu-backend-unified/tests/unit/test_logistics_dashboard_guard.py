from __future__ import annotations

from types import SimpleNamespace

from app.api.v1 import logistics as logistics_api


class _ExecResult:
    def __init__(self, value):
        self._value = value

    def first(self):
        return self._value


class _FakeSession:
    def __init__(self, driver):
        self._driver = driver

    def exec(self, _statement):
        return _ExecResult(self._driver)


def test_get_driver_dashboard_resolves_driver_profile_symbol(monkeypatch):
    """
    Regression guard for NameError on DriverProfile in /logistics/dashboard.
    """
    driver = SimpleNamespace(id=42, user_id=1)
    session = _FakeSession(driver)
    current_user = SimpleNamespace(id=1)

    monkeypatch.setattr(
        "app.services.driver_service.DriverService.get_driver_dashboard_stats",
        lambda _session, driver_id: {"driver_id": driver_id, "deliveries_today": 5},
    )

    response = logistics_api.get_driver_dashboard(
        session=session,
        current_user=current_user,
    )

    assert response.success is True
    assert response.data["driver_id"] == 42

