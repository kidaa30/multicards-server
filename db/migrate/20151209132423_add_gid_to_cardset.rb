class AddGidToCardset < ActiveRecord::Migration
  def change
    add_column :cardsets, :gid, :string
  end
end
