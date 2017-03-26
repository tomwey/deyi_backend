class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :uid
      t.string :avatar
      t.string :udid
      t.integer :balance,    default: 0 # 单位为分
      t.integer :total_earn, default: 0 # 单位为分
      t.integer :invites_count, default: 0
      t.string :private_token

      t.timestamps null: false
    end
    add_index :users, :uid, unique: true
    add_index :users, :udid, unique: true
    add_index :users, :private_token, unique: true
  end
end
