require_relative "../application_system_test_case"

class RunJobTest < ApplicationSystemTestCase
  test "run a job with arguments from the UI" do
    visit queues_path
    click_on "Run job"

    select "DummyJob", from: "Job class"
    fill_in "Arguments", with: "[ 123 ]"
    click_on "Enqueue job"

    assert_text(/Enqueued DummyJob/)
    assert_text "123"
  end

  test "show validation errors without losing the input" do
    visit queues_path
    click_on "Run job"

    select "DummyJob", from: "Job class"
    fill_in "Arguments", with: "definitely not json"
    click_on "Enqueue job"

    assert_text(/is not valid JSON/)
    assert_field "Arguments", with: "definitely not json"
  end
end
