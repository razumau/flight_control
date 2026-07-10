module FlightControl::JobsHelper
  def job_title(job)
    job.job_class_name
  end

  def job_arguments(job)
    renderable_job_arguments_for(job).join(", ")
  end

  def failed_job_error(job)
    "#{job.last_execution_error.error_class}: #{job.last_execution_error.message}"
  end

  def clean_backtrace?
    params["clean_backtrace"] == "true"
  end

  def failed_job_backtrace(job, server)
    if clean_backtrace? && server&.backtrace_cleaner
      server.backtrace_cleaner.clean(job.last_execution_error.backtrace).join("\n")
    else
      job.last_execution_error.backtrace.join("\n")
    end
  end

  def job_duration(job)
    return unless (seconds = job.duration)
    tag.span formatted_duration(seconds), title: "#{seconds.round(3)} seconds"
  end

  def attribute_names_for_job_status(status)
    case status.to_s
    when "failed"      then [ "Error", "Duration", "" ]
    when "blocked"     then [ "Queue", "Blocked by", "" ]
    when "finished"    then [ "Queue", "Duration", "Finished" ]
    when "scheduled"   then [ "Queue", "Scheduled", "" ]
    when "in_progress" then [ "Queue", "Run by", "Running for" ]
    else               []
    end
  end

  def job_delayed?(job)
    job.scheduled_at.before?(FlightControl.scheduled_job_delay_threshold.ago)
  end

  private
    DURATION_UNIT_ABBREVIATIONS = { years: "y", months: "mo", weeks: "w", days: "d", hours: "h", minutes: "m", seconds: "s" }

    def formatted_duration(seconds)
      if seconds < 1
        "#{(seconds * 1000).round} ms"
      elsif seconds < 60
        "#{seconds.round(1)} s"
      else
        ActiveSupport::Duration.build(seconds.round).parts
          .map { |unit, value| "#{value}#{DURATION_UNIT_ABBREVIATIONS[unit]}" }.join(" ")
      end
    end

    def renderable_job_arguments_for(job)
      job.serialized_arguments.collect do |argument|
        as_renderable_argument(argument)
      end
    end

    def as_renderable_argument(argument)
      case argument
      when Hash
        as_renderable_hash(argument)
      when Array
        as_renderable_array(argument)
      else
        ActiveJob::Arguments.deserialize([ argument ]).first
      end
    rescue ActiveJob::DeserializationError
      argument.to_s
    end

    def as_renderable_hash(argument)
      if argument["_aj_globalid"]
        # don't deserialize as the class might not exist in the host app running the engine
        argument["_aj_globalid"]
      elsif argument["_aj_serialized"] == "ActiveJob::Serializers::ModuleSerializer"
        argument["value"]
      elsif argument["_aj_serialized"]
        ActiveJob::Arguments.deserialize([ argument ]).first
      else
        FlightControl.job_arguments_filter.apply_to(argument)
          .without("_aj_symbol_keys", "_aj_ruby2_keywords")
          .transform_values { |v| as_renderable_argument(v) }
          .map { |k, v| "#{k}: #{v}" }
          .join(", ")
          .then { |s| "{#{s}}" }
      end
    end

    def as_renderable_array(argument)
      "[#{argument.collect { |part| as_renderable_argument(part) }.join(", ")}]"
    end
end
