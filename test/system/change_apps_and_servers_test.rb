require_relative "../application_system_test_case"

class ChangeAppsAndServersTest < ApplicationSystemTestCase
  setup do
    applications = FlightControl::Applications.new
    applications.add "Dummy", solid_queue: ActiveJob::QueueAdapters::SolidQueueAdapter.new
    applications.add "hey", solid_queue: ActiveJob::QueueAdapters::SolidQueueAdapter.new
    applications.add "bc4", us_east: ActiveJob::QueueAdapters::SolidQueueAdapter.new, us_west: ActiveJob::QueueAdapters::SolidQueueAdapter.new
    FlightControl.applications = applications
  end

  test "switch apps" do
    DummyJob.queue_as :hey_queue
    10.times { |index| DummyJob.perform_later(index) }

    visit queues_path
    hover_app_selector and_click: /hey/i
    assert_selector ".application-selector .navbar-link", text: "hey"

    click_on "hey_queue"
    assert_equal 10, job_row_elements.length
  end

  test "switch job servers" do
    DummyJob.queue_as :bc4_queue
    5.times { |index| DummyJob.perform_later(index) }

    visit queues_path
    hover_app_selector and_click: /bc4/i
    assert_selector ".server-selector li.is-active", text: "us_east"

    click_on_server_selector "us_west"
    assert_selector ".server-selector li.is-active", text: "us_west"

    click_on "bc4_queue"
    assert_equal 5, job_row_elements.length
  end
end
