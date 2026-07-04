Rails.application.routes.draw do
  root to: redirect("/jobs")

  mount FlightControl::Engine => "/jobs"
end
