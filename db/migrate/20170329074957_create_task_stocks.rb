class CreateTaskStocks < ActiveRecord::Migration
  def change
    create_table :task_stocks do |t|
      t.references :app_task, index: true, foreign_key: true
      t.integer :quantity
      t.integer :operator_id

      t.timestamps null: false
    end
    add_index :task_stocks, :operator_id
  end
end
