class ManyToManyUsersMatches < ActiveRecord::Migration
  def change
    create_table :matches_users, id: false do |table|
      table.belongs_to :user, index: true
      table.belongs_to :match, index: true
    end
  end
end
