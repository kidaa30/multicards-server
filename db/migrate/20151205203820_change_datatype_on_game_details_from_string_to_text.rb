class ChangeDatatypeOnGameDetailsFromStringToText < ActiveRecord::Migration
  def up
    change_column :games, :details, :text, :limit => nil
  end

  def down
    change_column :games, :details, :string
  end
end
