class CreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |table|
      table.column(:name, :string)
      table.column(:current_match, :integer)
      table.timestamps(null: true)
    end
  end
end
