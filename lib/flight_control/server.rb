require "active_job/queue_adapter"

class FlightControl::Server
  include FlightControl::IdentifiedByName
  include Workers
  include RecurringTasks
  include Serializable

  attr_reader :name, :queue_adapter, :application, :backtrace_cleaner

  def initialize(name:, queue_adapter:, application:, backtrace_cleaner: nil)
    super(name: name)
    unless queue_adapter.is_a?(ActiveJob::QueueAdapters::SolidQueueAdapter)
      raise FlightControl::Errors::UnsupportedAdapter,
        "Flight Control only supports Solid Queue, can't register server #{name} with #{queue_adapter.class}"
    end
    @queue_adapter = queue_adapter
    @application = application
    @backtrace_cleaner = backtrace_cleaner || FlightControl.backtrace_cleaner
  end

  def activating(&block)
    previous_adapter = ActiveJob::Base.current_queue_adapter
    ActiveJob::Base.current_queue_adapter = queue_adapter
    queue_adapter.activating(&block)
  ensure
    ActiveJob::Base.current_queue_adapter = previous_adapter
  end

  def queue_adapter_name
    ActiveJob.adapter_name(queue_adapter).underscore.to_sym
  end
end
