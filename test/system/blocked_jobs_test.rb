require_relative "../application_system_test_case"

class BlockedJobsTest < ApplicationSystemTestCase
  setup do
    # BlockingJob limits concurrency to 1: the first job stays ready and the second one gets blocked.
    BlockingJob.perform_later(10)
    BlockingJob.perform_later(20)

    visit jobs_path(:blocked)
  end

  test "displays blocked jobs with expiration date" do
    assert_equal 1, job_row_elements.length

    within_job_row "20" do
      assert_text "Expires"
    end
  end

  test "run now button works for blocked jobs" do
    assert_equal 1, job_row_elements.length

    within_job_row "20" do
      click_on "Run now"
    end

    assert_text "Dispatched"
    assert_empty job_row_elements
  end
end
