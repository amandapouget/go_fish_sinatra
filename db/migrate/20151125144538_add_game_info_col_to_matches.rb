class AddGameInfoColToMatches < ActiveRecord::Migration
  def change
    change_table :matches do |table|
      table.text :game_info
    end
  end
end
