module FlightControl::Server::RecurringTasks
  def recurring_tasks
    queue_adapter.recurring_tasks.collect do |task|
      FlightControl::RecurringTask.new(queue_adapter: queue_adapter, **task)
    end.sort_by(&:id)
  end

  def find_recurring_task(task_id)
    if (task = queue_adapter.find_recurring_task(task_id))
      FlightControl::RecurringTask.new(queue_adapter: queue_adapter, **task)
    else
      raise FlightControl::Errors::ResourceNotFound, "Recurring task with id '#{task_id}' not found"
    end
  end
end
