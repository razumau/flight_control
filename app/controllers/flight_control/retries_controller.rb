class FlightControl::RetriesController < FlightControl::ApplicationController
  include FlightControl::JobScoped

  def create
    @job.retry
    redirect_to application_jobs_url(@application, :failed, **jobs_filter_param), notice: "Retried job with id #{@job.job_id}"
  end

  private
    def jobs_relation
      ActiveJob.jobs.failed
    end
end
