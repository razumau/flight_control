# A container to register applications
class FlightControl::Applications < FlightControl::IdentifiedElements
  def add(name, queue_adapters_by_name = {})
    self << FlightControl::Application.new(name: name).tap do |application|
      application.add_servers(queue_adapters_by_name)
    end
  end
end
