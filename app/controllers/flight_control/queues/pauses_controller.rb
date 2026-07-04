class FlightControl::Queues::PausesController < FlightControl::ApplicationController
  include FlightControl::QueueScoped

  def create
    @queue.pause

    redirect_back fallback_location: application_queues_url(@application)
  end

  def destroy
    @queue.resume

    redirect_back fallback_location: application_queues_url(@application)
  end
end
