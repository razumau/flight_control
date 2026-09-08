module FlightControl::NavigationHelper
  attr_reader :page_title, :current_section

  def back_to_main_app_path
    FlightControl.back_to_main_app_path.presence || main_app.try(:root_path)
  end

  def navigation_sections
    {queues: ["Queues", application_queues_path(@application)]}.tap do |sections|
      supported_job_statuses.without(:pending).each do |status|
        sections[navigation_section_for_status(status)] = ["#{status.to_s.titleize} jobs (#{jobs_count_with_status(status)})", application_jobs_path(@application, status)]
      end

      sections[:workers] = ["Workers", application_workers_path(@application)] if workers_exposed?
      sections[:recurring_tasks] = ["Recurring tasks", application_recurring_tasks_path(@application)] if recurring_tasks_supported?
      sections[:job_launches] = ["Run job", new_application_job_launch_path(@application)]
    end
  end

  def navigation_section_for_status(status)
    if status.nil? || status == :pending
      :queues
    else
      :"#{status}_jobs"
    end
  end

  def navigation(title: nil, section: nil)
    @page_title = title
    @current_section = section
  end

  def selected_application?(application)
    FlightControl::Current.application.name == application.name
  end

  def selectable_applications
    FlightControl.applications.reject { |app| selected_application?(app) }
  end

  def selected_server?(server)
    FlightControl::Current.server.name == server.name
  end

  def jobs_count_with_status(status)
    count = ActiveJob.jobs.with_status(status).count
    if count.infinite?
      "..."
    else
      number_to_human(count,
        format: "%n%u",
        units: {
          thousand: "K",
          million: "M",
          billion: "B",
          trillion: "T",
          quadrillion: "Q"
        })
    end
  end
end
