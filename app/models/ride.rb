class Ride < ApplicationRecord
  belongs_to :user, foreign_key: "user_id"

  scope :hard, -> { where(kind: 'hard') }
  scope :soft, -> { where(kind: 'soft') }
  scope :kind, -> { distinct.pluck(:kind) }
  scope :by_user_id, ->(user_id) { where(user_id: user_id) }
  scope :years_of_rides, -> { (minimum_year..Date.today.year).to_a }

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

  def self.distance_by_date(date)
    start_on = date.to_date.beginning_of_month
    end_on = date.to_date.end_of_month
    Ride.where('date BETWEEN ? AND ?', start_on, end_on).sum(:distance)
  end

  # sum of distance monthly every year
  def self.distance_by_date(date)
    start_on = date.to_date.beginning_of_month
    end_on = date.to_date.end_of_month
    distance_sum = (Ride.where('date BETWEEN ? AND ?', start_on, end_on).sum(:distance))
    distance_sum
  end

  def self.differance(year)
    distance_by_year_to_date(year) - distance_by_year_to_date(year - 1)
  end

  def self.dynamic(year)
    (distance_by_year_to_date(year) / distance_by_year_to_date(year - 1) - 1) * 100
  end

  # sum of distance from begin of the year to today (month-day)
  def self.distance_by_year_to_date(year)
    year_differance = Time.zone.now.year - year
    start_of_year = (Time.zone.now - year_differance.year).beginning_of_year
    end_of_date = Time.zone.now - year_differance.year
    Ride.where('date BETWEEN ? AND ?', start_of_year, end_of_date).sum(:distance)
  end

  # earliest year of all rides
  def self.minimum_year
    Ride.minimum('date').year
  end

  # sum of distance yearly
  def self.distance_by_year(year)
    rides_by_year(year).sum('distance')
  end

  # sum of ride time yearly
  def self.time_by_year(year)
    Time.zone.at((rides_time_by_year(year).sum('hours') * 3600) + (rides_time_by_year(year).sum('minutes') * 60) + rides_time_by_year(year).sum('seconds')).strftime('%H:%M:%S')
  end

  # calculating average speed
  def self.average_speed_by_year(year)
    average_speed = rides_by_year(year).sum('distance') / time_to_hours_by_year(year).to_f
    '%.2f' % average_speed
  end

  # # calculating average speed by hard kind
  # def self.average_speed_by_year_hard(year)
  #   average_speed_hard = rides_by_year(year).hard.sum('distance') / time_to_hours_by_year_hard(year).to_f
  #   '%.2f' % average_speed_hard
  # end

  # # calculating average speed by soft kind
  # def self.average_speed_by_year_soft(year)
  #   average_speed_soft = rides_by_year(year).soft.sum('distance') / time_to_hours_by_year_soft(year).to_f
  #   '%.2f' % average_speed_soft
  # end

  # calculating average distance per ride
  def self.average_distance_by_year(year)
    '%.2f' % (rides_by_year(year).sum('distance') / count_of_rides(year).count)
  end

  # # calculating average distance by hard kind per ride
  # def self.average_distance_by_year_hard(year)
  #   '%.2f' % (rides_by_year(year).hard.sum('distance') / count_of_rides(year).hard.count)
  # end

  # # calculating average distance by soft kind per ride
  # def self.average_distance_by_year_soft(year)
  #   '%.2f' % (rides_by_year(year).soft.sum('distance') / count_of_rides(year).soft.count)
  # end

  # calculating average pace per ride
  def self.counting_average_pace(year)
    average_pace = time_to_minutes_by_year(year).to_f / rides_by_year(year).sum('distance')
    whole_number = average_pace.floor(0)
    # change decimals to time seconds
    decimal_number = '%02d' % ((average_pace - average_pace.floor(0)) * 60).floor(0)
    whole_number.to_s + ':' + decimal_number.to_s + ' min/km'
  end

  # # calculating average pace by hard kind per ride
  # def self.counting_average_pace_hard(year)
  #   average_pace = time_to_minutes_by_year_hard(year).to_f / rides_by_year(year).hard.sum('distance')
  #   whole_number = average_pace.floor(0)
  #   # change decimals to time seconds
  #   decimal_number = '%02d' % ((average_pace - average_pace.floor(0)) * 60).floor(0)
  #   whole_number.to_s + ':' + decimal_number.to_s + ' min/km'
  # end

  # # calculating average pace by soft kind per ride
  # def self.counting_average_pace_soft(year)
  #   average_pace = time_to_minutes_by_year_soft(year).to_f / rides_by_year(year).soft.sum('distance')
  #   whole_number = average_pace.floor(0)
  #   # change decimals to time seconds
  #   decimal_number = '%02d' % ((average_pace - average_pace.floor(0)) * 60).floor(0)
  #   whole_number.to_s + ':' + decimal_number.to_s + ' min/km'
  # end

  # quantity of rides per year
  def self.quantity_of_rides(year)
    count_of_rides(year).count
  end

  # # quantity of rides per year by hard kind
  # def self.quantity_of_rides_hard(year)
  #   count_of_rides(year).hard.count
  # end

  # # quantity of rides per year by soft kind
  # def self.quantity_of_rides_soft(year)
  #   count_of_rides(year).soft.count
  # end

  private

  def self.start_of_year(year)
    year.to_date.beginning_of_year
  end

  def self.end_of_year(year)
    year.to_date.end_of_year
  end

  def self.rides_by_year(year)
    Ride.where(date: (start_of_year(year)..end_of_year(year)))
  end

  def self.count_of_rides(year)
    rides_by_year(year)
  end

  def self.rides_time_by_year(year)
    Ride.where(date: (start_of_year(year)..end_of_year(year)))
  end

  def self.time_to_hours_by_year(year)
    Time.zone.at((rides_by_year(year)).sum('hours').to_f + (rides_by_year(year).sum('minutes').to_f / 60) + (rides_by_year(year).sum('seconds').to_f / 3600))
  end

  def self.time_to_hours_by_year_hard(year)
    Time.zone.at((rides_by_year(year)).hard.sum('hours').to_f + (rides_by_year(year).hard.sum('minutes').to_f / 60) + (rides_by_year(year).hard.sum('seconds').to_f / 3600))
  end

  def self.time_to_hours_by_year_soft(year)
    Time.zone.at((rides_by_year(year)).soft.sum('hours').to_f + (rides_by_year(year).soft.sum('minutes').to_f / 60) + (rides_by_year(year).soft.sum('seconds').to_f / 3600))
  end

  def self.time_to_minutes_by_year(year)
    Time.zone.at(((rides_by_year(year)).sum('hours').to_f * 60) + rides_by_year(year).sum('minutes').to_f + (rides_by_year(year).sum('seconds').to_f / 60))
  end

  def self.time_to_minutes_by_year_hard(year)
    Time.zone.at(((rides_by_year(year)).hard.sum('hours').to_f * 60) + rides_by_year(year).hard.sum('minutes').to_f + (rides_by_year(year).hard.sum('seconds').to_f / 60))
  end

  def self.time_to_minutes_by_year_soft(year)
    Time.zone.at(((rides_by_year(year)).soft.sum('hours').to_f * 60) + rides_by_year(year).soft.sum('minutes').to_f + (rides_by_year(year).soft.sum('seconds').to_f / 60))
  end
end
