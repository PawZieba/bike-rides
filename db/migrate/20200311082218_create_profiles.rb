class CreateProfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :profiles do |t|
      t.string :nickname
      t.bigint :user_id

      t.timestamps
    end
    add_foreign_key :profiles, :users
  end
end
