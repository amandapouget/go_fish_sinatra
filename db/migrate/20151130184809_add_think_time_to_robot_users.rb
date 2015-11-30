class AddThinkTimeToRobotUsers < ActiveRecord::Migration
  def change
    change_table :users do |table|
      table.integer :think_time
    end
  end
end
