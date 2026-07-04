class FlightControl::ApplicationController < FlightControl.base_controller_class.constantize
  ActionController::Base::MODULES.each do |mod|
    include mod unless self < mod
  end

  layout "flight_control/application"

  # Include helpers if not already included
  helper FlightControl::ApplicationHelper unless self < FlightControl::ApplicationHelper
  helper Importmap::ImportmapTagsHelper unless self < Importmap::ImportmapTagsHelper

  include FlightControl::BasicAuthentication
  include FlightControl::ApplicationScoped, FlightControl::NotFoundRedirections
  include FlightControl::AdapterFeatures
  include FlightControl::JobFilters

  around_action :set_current_locale

  private
    def default_url_options
      { server_id: FlightControl::Current.server }
    end

    def set_current_locale(&block)
      @previous_config = I18n.config
      I18n.config = FlightControl::I18nConfig.new
      I18n.with_locale(:en, &block)
    ensure
      I18n.config = @previous_config
      @previous_config = nil
    end
end
