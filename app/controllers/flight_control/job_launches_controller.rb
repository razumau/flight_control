class FlightControl::JobLaunchesController < FlightControl::ApplicationController
  before_action :set_form_options

  def new
    @job_launch = FlightControl::JobLaunch.new
  end

  def create
    @job_launch = FlightControl::JobLaunch.new(job_launch_params)

    if job = @job_launch.enqueue
      redirect_to application_job_path(@application, job.job_id), notice: "Enqueued #{@job_launch.job_class_name} with job id #{job.job_id}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def set_form_options
      @job_classes = FlightControl::JobLaunch.job_classes
      @queue_names = ActiveJob.queues.map(&:name)
    end

    def job_launch_params
      params.require(:job_launch).permit(:job_class_name, :arguments_json, :queue_name)
    end
end
