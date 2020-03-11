class Profile < ApplicationRecord
  belongs_to :user, foreign_key: "user_id"

  validates :nickname,
    presence: true, uniqueness: true
end
