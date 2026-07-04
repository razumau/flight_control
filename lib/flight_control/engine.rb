require "importmap-rails"
require "turbo-rails"
require "stimulus-rails"

module FlightControl
  class Engine < ::Rails::Engine
    isolate_namespace FlightControl

    rake_tasks do
      load "flight_control/tasks.rb"
    end

    initializer "flight_control.middleware" do |app|
      if app.config.api_only
        config.middleware.use ActionDispatch::Flash
        config.middleware.use ::Rack::MethodOverride
      end
    end

    config.flight_control = ActiveSupport::OrderedOptions.new unless config.try(:flight_control)

    config.before_initialize do
      config.flight_control.applications = FlightControl::Applications.new
      config.flight_control.backtrace_cleaner ||= Rails::BacktraceCleaner.new

      config.flight_control.each do |key, value|
        FlightControl.public_send("#{key}=", value)
      end

      if FlightControl.adapters.empty?
        FlightControl.adapters << (config.active_job.queue_adapter || :solid_queue)
      end

      unless FlightControl.adapters.all? { |adapter| adapter.to_sym == :solid_queue }
        unsupported = FlightControl.adapters.reject { |adapter| adapter.to_sym == :solid_queue }
        raise FlightControl::Errors::UnsupportedAdapter,
          "Flight Control only supports Solid Queue, but the following adapters are configured: #{unsupported.join(", ")}"
      end
    end

    initializer "flight_control.http_basic_auth" do |app|
      FlightControl.http_basic_auth_user ||= app.credentials.dig(:flight_control, :http_basic_auth_user)
      FlightControl.http_basic_auth_password ||= app.credentials.dig(:flight_control, :http_basic_auth_password)
    end

    initializer "flight_control.active_job.extensions" do
      ActiveSupport.on_load :active_job do
        include ActiveJob::Querying
        include ActiveJob::Executing
        include ActiveJob::Failed
        ActiveJob.extend ActiveJob::Querying::Root
      end
    end

    config.before_initialize do
      ActiveJob::QueueAdapters::SolidQueueAdapter.prepend ActiveJob::QueueAdapters::SolidQueueExt
    end

    config.after_initialize do |app|
      if FlightControl.applications.empty?
        queue_adapters_by_name = FlightControl.adapters.each_with_object({}) do |adapter, hsh|
          hsh[adapter] = ActiveJob::QueueAdapters.lookup(adapter).new
        end

        FlightControl.applications.add(app.class.module_parent.name, queue_adapters_by_name)
      end
    end

    console do
      require "irb"

      IRB::Command.register :connect_to, Console::ConnectTo
      IRB::Command.register :jobs_help, Console::JobsHelp

      IRB::Context.prepend(FlightControl::Console::Context)

      FlightControl.delay_between_bulk_operation_batches = 2
      FlightControl.logger = ActiveSupport::Logger.new(STDOUT)

      if FlightControl.show_console_help
        puts "\n\nType 'jobs_help' to see how to connect to the available job servers to manage jobs\n\n"
      end
    end

    initializer "flight_control.assets" do |app|
      app.config.assets.paths << root.join("app/assets/stylesheets")
      app.config.assets.paths << root.join("app/javascript")
      app.config.assets.precompile += %w[ flight_control_manifest ]
    end

    initializer "flight_control.importmap", after: "importmap" do |app|
      FlightControl.importmap.draw(root.join("config/importmap.rb"))
      if app.config.importmap.sweep_cache && app.config.reloading_enabled?
        FlightControl.importmap.cache_sweeper(watches: root.join("app/javascript"))

        ActiveSupport.on_load(:action_controller_base) do
          before_action { FlightControl.importmap.cache_sweeper.execute_if_updated }
        end
      end
    end
  end
end
