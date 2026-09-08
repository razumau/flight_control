Rails.application.routes.draw do
  root to: redirect("/jobs")
  resource :session, only: :new

  mount FlightControl::Engine => "/jobs"
end
