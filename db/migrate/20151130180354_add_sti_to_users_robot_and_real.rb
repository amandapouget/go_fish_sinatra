class AddStiToUsersRobotAndReal < ActiveRecord::Migration
  def change
    change_table :users do |table|
      table.text :type
    end
  end
end
