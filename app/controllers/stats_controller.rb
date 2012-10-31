class StatsController < ApplicationController
  def index
    @timeframe = params[:timeframe] || :current_week
    @stats =
      Activity.where(:created_at => timeframe(@timeframe))
      .joins(:user)
      .joins(:tracker)
      .select("users.name as name,sum(coalesce(activities.points, trackers.points)) as points")
      .group('users.name')
      .order("points desc")
  end

  private
    def timeframe(which)
      now = Time.now.utc
      case which.to_sym
        when :current_week
          (now.beginning_of_week...now.end_of_week)
        when :last_week
          now -=  7.days
          (now.beginning_of_week...now.end_of_week)
        when :today
          (now.beginning_of_day...now.end_of_day)
        when :yesterday
          now -= 1.day
          (now.beginning_of_day...now.end_of_day)
        when :current_month
          (now.beginning_of_month...now.end_of_month)
        when :last_month
          now -= 1.month
          (now.beginning_of_month...now.end_of_month)
      end
    end
end
