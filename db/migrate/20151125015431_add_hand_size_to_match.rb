class AddHandSizeToMatch < ActiveRecord::Migration
  def change
    change_table :matches do |table|
      table.integer :hand_size
    end
  end
end
