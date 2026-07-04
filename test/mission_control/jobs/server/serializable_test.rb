require "test_helper"

class MissionControl::Jobs::Server::SerializableTest < ActiveSupport::TestCase
  setup do
    applications = MissionControl::Jobs::Applications.new
    applications.add :bc4, us_east: ActiveJob::QueueAdapters::SolidQueueAdapter.new, us_west: ActiveJob::QueueAdapters::SolidQueueAdapter.new
    applications.add :hey, solid_queue: ActiveJob::QueueAdapters::SolidQueueAdapter.new
    MissionControl::Jobs.applications = applications

    @bc4_us_east = MissionControl::Jobs.applications[:bc4].servers[:us_east]
    @hey = MissionControl::Jobs.applications[:hey].servers[:solid_queue]
  end

  test "generate a global id for a server" do
    assert_equal "bc4:us_east", @bc4_us_east.to_global_id
    assert_equal "hey", @hey.to_global_id
  end

  test "locate a server for a global id" do
    assert_equal @bc4_us_east, MissionControl::Jobs::Server.from_global_id("bc4:us_east")
    assert_equal @hey, MissionControl::Jobs::Server.from_global_id("hey:solid_queue")
  end

  test "raise an error when trying to locate a missing server" do
    assert_raises MissionControl::Jobs::Errors::ResourceNotFound do
      MissionControl::Jobs::Server.from_global_id("bc4:us_paris")
    end

    assert_raises MissionControl::Jobs::Errors::ResourceNotFound do
      MissionControl::Jobs::Server.from_global_id("backpack:us_east")
    end

    assert_raises MissionControl::Jobs::Errors::ResourceNotFound do
      MissionControl::Jobs::Server.from_global_id("backpack")
    end
  end
end
