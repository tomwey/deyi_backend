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
  
  state_machine initial: :pending do
    state :canceled
    state :expired
    state :completed
    
    # 取消任务
    event :cancel do
      transition :pending => :canceled
    end
    
    # 过期任务
    event :expire do
      transition :pending => :expired
    end
    
    # 完成任务
    event :complete do
      transition :pending => :completed
    end
    
  end
end
