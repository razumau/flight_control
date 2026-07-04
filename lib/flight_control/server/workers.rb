module FlightControl::Server::Workers
  def workers_relation
    FlightControl::WorkersRelation.new(queue_adapter: queue_adapter)
  end

  def find_worker(worker_id)
    if worker = queue_adapter.find_worker(worker_id)
      FlightControl::Worker.new(queue_adapter: queue_adapter, **worker)
    else
      raise FlightControl::Errors::ResourceNotFound, "Worker with id '#{worker_id}' not found"
    end
  end
end
