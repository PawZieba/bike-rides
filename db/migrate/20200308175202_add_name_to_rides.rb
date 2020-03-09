class AddNameToRides < ActiveRecord::Migration[6.0]
  def change
    add_column :rides, :name, :string, after: :date
  end
end
