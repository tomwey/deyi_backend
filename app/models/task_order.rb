class TaskOrder < ActiveRecord::Base
  belongs_to :app_task
  belongs_to :user
  
  scope :in_progress, -> { with_state(:pending) }
  scope :completed, -> { with_state(:completed) }
  scope :expired,   -> { with_state(:expired) }
  scope :canceled,  -> { with_state(:canceled) }
    
  before_create :create_order_no
  def create_order_no
    begin
      self.order_no = Time.now.to_s(:number) + Time.now.nsec.to_s
    end while self.class.exists?(:order_no => order_no)
  end
  
  after_create :update_stock
  def update_stock
    app_task.stock -= 1 if app_task.stock >= 1
    app_task.save!
    
    # 添加30分钟后自动失效功能
    CancelTaskJob.set(wait: (CommonConfig.task_expire_duration || 30).minutes).perform_later(self.id)
  end
  
  def add_stock_count
    app_task.stock += 1
    app_task.save!
  end
  
  state_machine initial: :pending do
    state :canceled
    state :expired
    state :completed
    
    # 取消任务
    after_transition :pending => :canceled do |order, transition|
      order.add_stock_count
    end
    event :cancel do
      transition :pending => :canceled
    end
    
    # 过期任务
    after_transition :pending => :expired do |order, transition|
      order.add_stock_count
    end
    event :expire do
      transition :pending => :expired
    end
    
    # 完成任务
    after_transition :pending => :completed do |order, transition|
      order.complete_task
    end
    event :complete do
      transition :pending => :completed
    end
    
  end
end
