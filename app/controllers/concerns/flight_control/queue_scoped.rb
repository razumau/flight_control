module FlightControl::QueueScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_queue
  end

  private
    def set_queue
      @queue = ActiveJob.queues[params[:queue_id]] or raise FlightControl::Errors::ResourceNotFound, "Queue '#{params[:queue_id]}' not found"
    end
end
