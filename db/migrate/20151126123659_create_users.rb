class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :socket_id
      t.string :details

      t.timestamps
    end
  end
end
