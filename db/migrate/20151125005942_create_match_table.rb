class CreateMatchTable < ActiveRecord::Migration
  def change
    create_table(:matches) do |table|
      table.boolean :over, default: false, null: false
      table.text :message
      table.timestamps(null: true)
    end
  end
end
