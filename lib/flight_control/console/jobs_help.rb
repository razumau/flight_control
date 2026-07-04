require "irb/command"

module FlightControl::Console
  class JobsHelp < IRB::Command::Base
    category "Flight Control jobs"
    description "Show help for managing jobs"

    def execute(*)
      puts "You are currently connected to #{FlightControl::Current.server}" if FlightControl::Current.server

      puts "You can connect to a job server with"
      puts %(  connect_to <app_id>:<server_id>\n\n)

      puts "Available job servers:\n"

      FlightControl.applications.each do |application|
        application.servers.each do |server|
          puts "  * #{server.to_global_id}"
        end
      end
    end
  end
end
