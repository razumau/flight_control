class FlightControl::JobLaunch
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :job_class_name, :string
  attribute :arguments_json, :string, default: "[]"
  attribute :queue_name, :string

  validates :job_class_name, presence: true
  validate :validate_job_class
  validate :validate_arguments

  # Job classes defined in the host application. Not memoized on purpose:
  # class reloading in development would leave stale classes behind.
  def self.job_classes
    Rails.application.eager_load! unless Rails.application.config.eager_load
    ActiveJob::Base.descendants.select { |job_class| job_class.name.present? && implements_perform?(job_class) }.sort_by(&:name)
  end

  # ActiveJob::Execution defines a perform placeholder that raises NotImplementedError,
  # so abstract base classes like ApplicationJob still own that placeholder.
  def self.implements_perform?(job_class)
    job_class.instance_method(:perform).owner != ActiveJob::Execution
  end

  def enqueue
    return nil unless valid?

    job = configured_job_class.perform_later(*positional_arguments, **keyword_arguments)
    if job&.successfully_enqueued?
      job
    else
      errors.add(:base, "job could not be enqueued#{": #{job.enqueue_error.message}" if job&.enqueue_error}")
      nil
    end
  rescue => error
    errors.add(:base, "job could not be enqueued: #{error.message}")
    nil
  end

  private

  def job_class
    # Only classes from the discovered list can be launched; never constantize user input.
    self.class.job_classes.detect { |klass| klass.name == job_class_name }
  end

  def configured_job_class
    queue_name.present? ? job_class.set(queue: queue_name) : job_class
  end

  def parsed_arguments
    @parsed_arguments ||= JSON.parse(arguments_json.presence || "[]")
  end

  def positional_arguments
    parsed_arguments.last.is_a?(Hash) ? parsed_arguments[0...-1] : parsed_arguments
  end

  def keyword_arguments
    parsed_arguments.last.is_a?(Hash) ? parsed_arguments.last.transform_keys(&:to_sym) : {}
  end

  def validate_job_class
    if job_class_name.present? && job_class.nil?
      errors.add(:job_class_name, "is not a job class of this application")
    end
  end

  def validate_arguments
    errors.add(:arguments_json, "must be a JSON array") unless parsed_arguments.is_a?(Array)
  rescue JSON::ParserError
    errors.add(:arguments_json, "is not valid JSON")
  end
end
