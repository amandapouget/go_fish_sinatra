class RenameGameInfoToGameInMatch < ActiveRecord::Migration
  def change
    rename_column :matches, :game_info, :game
  end
end
