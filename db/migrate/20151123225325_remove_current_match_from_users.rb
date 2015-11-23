class RemoveCurrentMatchFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :current_match
  end
end
