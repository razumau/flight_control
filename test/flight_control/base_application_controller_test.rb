require "test_helper"

class FlightControl::BaseApplicationControllerTest < ActiveSupport::TestCase
  test "engine's ApplicationController inherits from host's ApplicationController by default" do
    assert FlightControl::ApplicationController < ApplicationController
  end

  test "engine's ApplicationController inherits from configured base_controller_class" do
    assert FlightControl::ApplicationController < MyApplicationController
  end
end
