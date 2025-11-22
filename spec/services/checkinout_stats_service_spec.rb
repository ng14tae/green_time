require 'rails_helper'

RSpec.describe CheckinoutStatsService, type: :service do
  describe '.monthly_stats' do
    context 'when there are no records for the user' do
      it 'returns zeros' do
        user = User.create!(email: 'no_records@example.com', password: 'password')

        stats = described_class.monthly_stats(user)

        expect(stats[:total_days]).to eq(0)
        expect(stats[:total_hours]).to eq(0)
        expect(stats[:average_hours]).to eq(0)
      end
    end

    context 'when there are records for the user in the month' do
      it 'calculates total and average hours' do
        user = User.create!(email: 'with_records@example.com', password: 'password')

        # create two records in current month
        today = Time.current
        checkin1 = today.change(hour: 9, min: 0, sec: 0)
        checkout1 = today.change(hour: 17, min: 0, sec: 0) # 8h

        checkin2 = (today - 1.day).change(hour: 9, min: 30, sec: 0)
        checkout2 = (today - 1.day).change(hour: 18, min: 0, sec: 0) # 8.5h

        CheckinoutRecord.create!(user: user, checkin_time: checkin1, checkout_time: checkout1)
        CheckinoutRecord.create!(user: user, checkin_time: checkin2, checkout_time: checkout2)

        stats = described_class.monthly_stats(user)

        expect(stats[:total_days]).to eq(2)
        expect(stats[:total_hours]).to be_within(0.001).of(16.5)
        expect(stats[:average_hours]).to be_within(0.001).of(8.25)
      end
    end
  end

  describe '.weekly_stats' do
    it 'calculates total_days and total_hours for current week' do
      user = User.create!(email: 'week_user@example.com', password: 'password')

      today = Time.current
      checkin = today.change(hour: 10, min: 0, sec: 0)
      checkout = today.change(hour: 15, min: 0, sec: 0) # 5h

      CheckinoutRecord.create!(user: user, checkin_time: checkin, checkout_time: checkout)

      stats = described_class.weekly_stats(user)

      expect(stats[:total_days]).to eq(1)
      expect(stats[:total_hours]).to be_within(0.001).of(5.0)
    end
  end
end
