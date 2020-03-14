class AddUserIdToRides < ActiveRecord::Migration[6.0]
  def change
    add_reference :rides, :user, after: :id, foreign_key: true
    end
end
