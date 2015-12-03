module Stchart
  module Date

    def short_date(date)
      return date.split('/')[1..date.length].join('/')
    end

    def monday(date)
      date.beginning_of_week
    end
    def tuesday(date)
      date.beginning_of_week + 1.days
    end
    def wednesday(date)
      date.beginning_of_week + 2.days
    end
    def thursday(date)
      date.beginning_of_week + 3.days
    end
    def friday(date)
      date.beginning_of_week + 4.days
    end
    def saturday(date)
      date.beginning_of_week + 5.days
    end
    def sunday(date)
      date.beginning_of_week + 6.days
    end

    def friday?(date)
      ::Date.new(*date.split('/').map{|t| t.to_i }).friday?
    end

    def release_dates(release: 'mitaka')
      release = Stchart::RELEASES.find{|v| v[1] == release }
      release_begin_date = Stchart::RELEASES[release[0] - 1][2]
      release_date = release[2]
      return [release_date, release_begin_date]
    end

    def release_interval(release: 'mitaka', interval: 7, flag: nil)
      release_date, day = release_dates(release: release)
      now = ::Date.today
      begin
        day = day + interval.days
        day = self.send(flag, day) if flag
        actual_day = day
        actual_day = now if day > now
        yield day.beginning_of_day, actual_day.beginning_of_day
      end while actual_day < now && actual_day < release_date
    end
  end
end
