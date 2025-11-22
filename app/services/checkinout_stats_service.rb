class CheckinoutStatsService
  class << self
    def monthly_stats(user)
      start_of_month = Time.current.beginning_of_month
      end_of_month = Time.current.end_of_month

      relation = CheckinoutRecord.where(
        user_id: user.id,
        checkin_time: start_of_month..end_of_month
      ).where.not(checkout_time: nil)

      total_days = relation.count
      # Postgres: sum interval in seconds, then convert to hours
      seconds = relation.sum("EXTRACT(EPOCH FROM (checkout_time - checkin_time))") || 0
      total_hours = seconds.to_f / 3600.0
      average_hours = total_days.zero? ? 0 : (total_hours / total_days)

      {
        total_days: total_days,
        total_hours: total_hours,
        average_hours: average_hours
      }
    end

    def weekly_stats(user)
      start_of_week = Time.current.beginning_of_week
      end_of_week = Time.current.end_of_week

      relation = CheckinoutRecord.where(
        user_id: user.id,
        checkin_time: start_of_week..end_of_week
      ).where.not(checkout_time: nil)

      total_days = relation.count
      seconds = relation.sum("EXTRACT(EPOCH FROM (checkout_time - checkin_time))") || 0
      total_hours = seconds.to_f / 3600.0

      {
        total_days: total_days,
        total_hours: total_hours
      }
    end
    private

    def total_hours_from_relation(relation)
      seconds = relation.sum("EXTRACT(EPOCH FROM (checkout_time - checkin_time))") || 0
      seconds.to_f / 3600.0
    end

    def average_hours_from_relation(relation)
      count = relation.count
      return 0 if count.zero?
      total_hours_from_relation(relation) / count
    end
  end
end
