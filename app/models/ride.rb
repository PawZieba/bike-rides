class Ride < ApplicationRecord
  belongs_to :user, foreign_key: "user_id"

  validates :date, :name, :distance, :hours, :minutes, :seconds, :kind,
  presence: true

  def calculating_speed
    speed = (distance / (hours.to_f + minutes.to_f / 60 + seconds.to_f / 3600))
    '%.2f' % speed + ' km/h'
  end

    def calculating_pace
      pace = (hours.to_f * 60 + minutes.to_f + seconds.to_f / 60) / distance
      # change decimals to time seconds
      decimal_number = '%02d' % ((pace - pace.floor(0)) * 60).floor(0)
      pace.floor(0).to_s + ':' + decimal_number.to_s + ' min/km'
    end

    def time_view
      sprintf('%02d', hours) + ':' + sprintf('%02d', minutes) + ':' + sprintf('%02d', seconds)
    end
end
