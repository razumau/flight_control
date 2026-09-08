require "test_helper"

class FlightControl::HostRouteHelpersTest < ActionDispatch::IntegrationTest
  # The helpers are defined by the :after_routes_loaded hook, and routes load lazily in test
  setup { Rails.application.reload_routes_unless_loaded }

  test "host route helpers used by the base controller resolve against the host app's routes" do
    get flight_control.application_queues_url(@application, require_authentication: true)
    assert_redirected_to "/session/new"
  end

  test "route helpers defined by both the host app and the engine keep resolving to the engine's" do
    assert_includes FlightControl::HostRouteHelpers.instance_methods, :new_session_path
    assert_not_includes FlightControl::HostRouteHelpers.instance_methods, :root_path
  end

  test "host route helpers are redefined when routes reload" do
    Rails.application.reload_routes!

    assert_includes FlightControl::HostRouteHelpers.instance_methods, :new_session_path
    get flight_control.application_queues_url(@application, require_authentication: true)
    assert_redirected_to "/session/new"
  end
end
