module FlightControl::Console::Context
  mattr_accessor :jobs_server

  def evaluate(*)
    if FlightControl::Current.server
      FlightControl::Current.server.activating { super }
    else
      super
    end
  end
end
