pin "application", to: "flight_control/application.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from FlightControl::Engine.root.join("app/javascript/flight_control/controllers"), under: "controllers", to: "flight_control/controllers"
pin_all_from FlightControl::Engine.root.join("app/javascript/flight_control/helpers"), under: "helpers", to: "flight_control/helpers"
