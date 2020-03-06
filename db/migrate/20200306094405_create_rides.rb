class CreateRides < ActiveRecord::Migration[6.0]
  def change
    create_table :rides do |t|
      t.date :date
      t.float :distance
      t.integer :hours
      t.integer :minutes
      t.integer :seconds
      t.string :kind
      t.string :image

      t.timestamps
    end
  end
end
