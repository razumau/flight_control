namespace :flight_control do
  desc "Configure HTTP Basic Authentication"
  task "authentication:configure" => :environment do
    FlightControl::Authentication.configure
  end
end
