class AddCardsetidToCard < ActiveRecord::Migration
  def change
    add_column :cards, :cardsetid, :integer
  end
end
