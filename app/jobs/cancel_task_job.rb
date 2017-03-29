class CancelTaskJob < ActiveJob::Base
  queue_as :scheduled_jobs
  
  def perform(id)
    order = TaskOrder.find_by(id: id)
    if order and order.can_expire?
      order.expire
    end
  end
  
end