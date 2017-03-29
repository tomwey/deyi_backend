class RenameColumnForAppTasks < ActiveRecord::Migration
  def change
    rename_column :app_tasks, :put_in_count, :stock
  end
end
