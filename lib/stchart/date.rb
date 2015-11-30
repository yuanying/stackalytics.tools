module Stchart
  module Date

    def short_date(date)
      return date.split('/')[1..date.length].join('/')
    end
  end
end
