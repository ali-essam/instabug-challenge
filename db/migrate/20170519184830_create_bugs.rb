class CreateBugs < ActiveRecord::Migration[5.1]
  def change
    create_table :bugs do |t|
      t.string :app_token
      t.integer :number
      t.string :status
      t.string :priority
      t.text :comment

      t.timestamps
    end
  end
end
