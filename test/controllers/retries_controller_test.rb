require "test_helper"

class FlightControl::JobsControllerTest < ActionDispatch::IntegrationTest
  test "retry job with invalid ID" do
    post flight_control.application_job_retry_url(@application, "unknown_id")
    assert_redirected_to flight_control.application_jobs_url(@application, :failed)
    follow_redirect!

    assert_select "article.is-danger", /Job with id 'unknown_id' not found/
  end

  test "retry jobs when there are multiple instances of the same job due to automatic retries" do
    job = AutoRetryingJob.perform_later

    perform_enqueued_jobs_async

    get flight_control.application_jobs_url(@application, :failed)
    assert_response :ok

    assert_select "tr.job", 1
    assert_select "tr.job", /AutoRetryingJob\s+Enqueued less than 5 seconds ago\s+AutoRetryingJob::RandomError/

    post flight_control.application_job_retry_url(@application, job.job_id)
    assert_redirected_to flight_control.application_jobs_url(@application, :failed)
    follow_redirect!

    assert_select "article.is-danger", text: /Job with id '#{job.job_id}' not found/, count: 0
    assert_select "tr.job", 0
  end
end
