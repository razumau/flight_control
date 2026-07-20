module FlightControl::AdapterFeatures
  extend ActiveSupport::Concern

  included do
    helper_method :supported_job_statuses, :queue_pausing_supported?, :workers_exposed?, :recurring_tasks_supported?
  end

  private

  def supported_job_statuses
    FlightControl::Current.server.queue_adapter.supported_job_statuses & ActiveJob::JobsRelation::STATUSES
  end

  def queue_pausing_supported?
    FlightControl::Current.server.queue_adapter.supports_queue_pausing?
  end

  def workers_exposed?
    FlightControl::Current.server.queue_adapter.exposes_workers?
  end

  def recurring_tasks_supported?
    FlightControl::Current.server.queue_adapter.supports_recurring_tasks?
  end
end
