require "test_helper"

class FlightControl::ServerTest < ActiveSupport::TestCase
  setup do
    @application = FlightControl.applications.first
  end

  test "activating a queue adapter" do
    current_adapter = ActiveJob::Base.queue_adapter
    new_adapter = ActiveJob::QueueAdapters::SolidQueueAdapter.new
    server = FlightControl::Server.new(name: "secondary", queue_adapter: new_adapter, application: @application)

    assert_equal current_adapter, ActiveJob::Base.queue_adapter

    server.activating do
      @executed = true
      assert_equal new_adapter, ActiveJob::Base.queue_adapter
    end

    assert @executed
    assert_equal current_adapter, ActiveJob::Base.queue_adapter
  end

  test "registering a server with a non-Solid Queue adapter raises an error" do
    assert_raises FlightControl::Errors::UnsupportedAdapter do
      FlightControl::Server.new(name: "async", queue_adapter: ActiveJob::QueueAdapters::AsyncAdapter.new, application: @application)
    end
  end
end
