class CreateTaskOrders < ActiveRecord::Migration
  def change
    create_table :task_orders do |t|
      t.string :order_no
      t.string :state, default: 'pending' # pending canceled expired completed
      t.references :app_task, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.decimal :price, precision: 6, scale: 2, null: false
      t.decimal :special_price, precision: 6, scale: 2, null: false
      t.datetime :commited_at # 提交校验任务的时间

      t.timestamps null: false
    end
    add_index :task_orders, :order_no, unique: true
    
  end
end
