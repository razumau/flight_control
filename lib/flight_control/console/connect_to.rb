require "irb/command"

module FlightControl::Console
  class ConnectTo < IRB::Command::Base
    category "Flight Control jobs"
    description "Connect to a job server"

    def execute(server_locator)
      server = FlightControl::Server.from_global_id(server_locator)
      FlightControl::Current.server = server

      puts "Connected to #{server_locator}"
    end
  end
end
