require "test_helper"

class FlightControl::JobLaunchesControllerTest < ActionDispatch::IntegrationTest
  test "show the form with the application's job classes" do
    get flight_control.new_application_job_launch_url(@application)
    assert_response :ok

    assert_select "option", "DummyJob"
    assert_select "option", "FailingJob"
    assert_select "option", {text: "ApplicationJob", count: 0} # no perform method
  end

  test "enqueue a job with positional arguments" do
    post flight_control.application_job_launches_url(@application),
      params: {job_launch: {job_class_name: "DummyJob", arguments_json: "[ 123 ]"}}

    job = SolidQueue::Job.last
    assert_equal "DummyJob", job.class_name
    assert_equal [123], job.arguments["arguments"]

    assert_redirected_to flight_control.application_job_url(@application, job.active_job_id)
    follow_redirect!
    assert_response :ok
    assert_select "article.is-success", /Enqueued DummyJob/
  end

  test "enqueue a job without arguments" do
    post flight_control.application_job_launches_url(@application),
      params: {job_launch: {job_class_name: "DummyJob", arguments_json: ""}}

    job = SolidQueue::Job.last
    assert_equal "DummyJob", job.class_name
    assert_equal [], job.arguments["arguments"]
  end

  test "a trailing JSON object is passed as keyword arguments" do
    post flight_control.application_job_launches_url(@application),
      params: {job_launch: {job_class_name: "DummyJob", arguments_json: '[ 123, { "author": "Jorge" } ]'}}

    job = SolidQueue::Job.last
    arguments = job.arguments["arguments"]
    assert_equal 123, arguments.first
    assert_equal "Jorge", arguments.last["author"]
    assert arguments.last.key?("_aj_ruby2_keywords"), "expected the trailing hash to be serialized as keyword arguments"
  end

  test "enqueue a job on a specific queue" do
    post flight_control.application_job_launches_url(@application),
      params: {job_launch: {job_class_name: "DummyJob", arguments_json: "[]", queue_name: "reports"}}

    assert_equal "reports", SolidQueue::Job.last.queue_name
  end

  test "reject a class that is not a job class" do
    post flight_control.application_job_launches_url(@application),
      params: {job_launch: {job_class_name: "Post", arguments_json: "[]"}}

    assert_response :unprocessable_entity
    assert_select "article.is-danger li", /is not a job class/
    assert_nil SolidQueue::Job.last
  end

  test "reject invalid JSON arguments" do
    post flight_control.application_job_launches_url(@application),
      params: {job_launch: {job_class_name: "DummyJob", arguments_json: "not json"}}

    assert_response :unprocessable_entity
    assert_select "article.is-danger li", /is not valid JSON/
    assert_nil SolidQueue::Job.last
  end

  test "reject JSON arguments that are not an array" do
    post flight_control.application_job_launches_url(@application),
      params: {job_launch: {job_class_name: "DummyJob", arguments_json: '{ "author": "Jorge" }'}}

    assert_response :unprocessable_entity
    assert_select "article.is-danger li", /must be a JSON array/
    assert_nil SolidQueue::Job.last
  end

  test "reject a missing job class" do
    post flight_control.application_job_launches_url(@application),
      params: {job_launch: {job_class_name: "", arguments_json: "[]"}}

    assert_response :unprocessable_entity
    assert_nil SolidQueue::Job.last
  end
end
