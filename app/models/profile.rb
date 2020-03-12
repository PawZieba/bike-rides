class Profile < ApplicationRecord
  belongs_to :user, foreign_key: "user_id", optional: true

  validates :nickname,
    presence: true, uniqueness: true
end
