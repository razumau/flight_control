class FlightControl::WorkersController < FlightControl::ApplicationController
  before_action :ensure_exposed_workers

  def index
    @workers_page = FlightControl::Page.new(workers_relation, page: params[:page].to_i)
    @workers_count = @workers_page.total_count
  end

  def show
    @worker = FlightControl::Current.server.find_worker(params[:id])
  end

  private

  def ensure_exposed_workers
    unless workers_exposed?
      redirect_to root_url, alert: "This server doesn't expose workers"
    end
  end

  def workers_relation
    FlightControl::Current.server.workers_relation
  end
end
