module FlightControl::ApplicationScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_application
    around_action :activating_job_server

    delegate :applications, to: FlightControl
  end

  private
    def set_application
      @application = find_application or raise FlightControl::Errors::ResourceNotFound, "Application not found"
      FlightControl::Current.application = @application
    end

    def find_application
      if params[:application_id]
        applications[params[:application_id]]
      else
        applications.first
      end
    end

    def activating_job_server(&block)
      @server = find_server or raise FlightControl::Errors::ResourceNotFound, "Server not found"
      FlightControl::Current.server = @server
      @server.activating(&block)
    end

    def find_server
      if params[:server_id]
        FlightControl::Current.application.servers[params[:server_id]]
      else
        @application.servers.first
      end
    end
end
