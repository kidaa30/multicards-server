class CreateCardsets < ActiveRecord::Migration
  def change
    create_table :cardsets do |t|
      t.string :language
      t.string :details

      t.timestamps
    end
  end
end
