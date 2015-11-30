class AddHandSizeToMatch < ActiveRecord::Migration
  def change
    change_table :matches do |table|
      table.integer :hand_size, default: 5
    end
  end
end
