require "solid_queue"

require "flight_control/version"
require "flight_control/engine"

require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.inflector = Zeitwerk::GemInflector.new(__FILE__)
loader.push_dir(__dir__)
loader.ignore("#{__dir__}/flight_control/tasks.rb")
loader.setup

module FlightControl
  mattr_accessor :adapters, default: Set.new
  mattr_accessor :applications, default: FlightControl::Applications.new
  mattr_accessor :base_controller_class, default: "::ApplicationController"

  mattr_accessor :internal_query_count_limit, default: 500_000 # Hard limit to keep unlimited count queries fast enough
  mattr_accessor :delay_between_bulk_operation_batches, default: 0
  mattr_accessor :scheduled_job_delay_threshold, default: 1.minute

  mattr_accessor :logger, default: ActiveSupport::Logger.new(nil)

  mattr_accessor :show_console_help, default: true
  mattr_accessor :backtrace_cleaner
  mattr_accessor :back_to_main_app_path

  mattr_accessor :importmap, default: Importmap::Map.new

  mattr_accessor :http_basic_auth_user
  mattr_accessor :http_basic_auth_password
  mattr_accessor :http_basic_auth_enabled, default: true

  mattr_accessor :filter_arguments, default: []

  def self.job_arguments_filter
    FlightControl::ArgumentsFilter.new(filter_arguments)
  end
end
