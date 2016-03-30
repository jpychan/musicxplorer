module Publisher
  extend self
 
  def broadcast(event, payload={})
    if block_given?
      ActiveSupport::Notifications.instrument(event, payload) do 
        yield
      end
    else
      ActiveSupport::Notifications.instrument(event, payload)
    end
  end
end
