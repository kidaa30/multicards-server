class AddSetIdToCard < ActiveRecord::Migration
  def change
    add_column :cards, :set_id, :integer
  end
end
