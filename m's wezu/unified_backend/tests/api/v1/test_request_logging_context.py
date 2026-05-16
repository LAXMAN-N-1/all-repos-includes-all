from types import SimpleNamespace

from app.api.errors.handlers import _request_log_context


def test_request_log_context_includes_role_and_permission_fields():
    request = SimpleNamespace(
        method="GET",
        url=SimpleNamespace(path="/api/v1/stations/"),
        query_params={"limit": "200", "skip": "0"},
        state=SimpleNamespace(
            request_id="req-1",
            correlation_id="corr-1",
            client_ip="10.0.0.1",
            user_id=37,
            user_roles=["dispatcher", "logistics_manager"],
            primary_role="logistics_manager",
            claimed_actor_role="warehouse_operator",
            required_permission="station:view:global",
            allowed_roles=["logistics_manager", "operations_admin"],
            auth_error=None,
        ),
    )

    context = _request_log_context(request)

    assert context["user_roles"] == ["dispatcher", "logistics_manager"]
    assert context["primary_role"] == "logistics_manager"
    assert context["claimed_actor_role"] == "warehouse_operator"
    assert context["required_permission"] == "station:view:global"
    assert context["allowed_roles"] == ["logistics_manager", "operations_admin"]
