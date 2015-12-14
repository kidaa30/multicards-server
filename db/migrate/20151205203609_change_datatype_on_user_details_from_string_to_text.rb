class ChangeDatatypeOnUserDetailsFromStringToText < ActiveRecord::Migration
  def up
    change_column :users, :details, :text, :limit => nil
  end

  def down
    change_column :users, :details, :string
  end
end
