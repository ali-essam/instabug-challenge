class CreateStates < ActiveRecord::Migration[5.1]
  def change
    create_table :states do |t|
      t.string :device
      t.string :os
      t.integer :memory
      t.integer :storage

      t.timestamps
    end
  end
end
