require 'stchart/common'

module Stchart
  module Data
    BASE_URI = "http://stackalytics.com/api/1.0/stats/"

    def fetch_company(
        release: 'mitaka',
        company: 'NEC',
        interval: 7,
        target: 'engineers',
        metric: 'commits',
        flag: nil)
      base_uri = "#{BASE_URI}#{target}?release=#{release}&metric=#{metric}&company=#{company}"

      tmp_dir = File.join(Stchart::ROOT, '.tmp', company, target)
      FileUtils.mkdir_p(tmp_dir)

      raw_data = {}

      release_interval(
        release: release,
        interval: interval,
        flag: flag
      ) do |day, actual_day|

        tmp_file = File.join(tmp_dir, "#{actual_day.to_i.to_s}.#{metric}.json")
        unless File.file?(tmp_file)
          data_uri = "#{base_uri}&end_date=#{actual_day.to_i}"
        else
          data_uri = tmp_file
        end
        json_data = nil
        begin
          open(data_uri) do |io|
            json_data = io.read
            raw_data[day] = JSON.parse( json_data )
          end
        rescue => ex
          puts "#{data_uri} failed"
          raise ex
        end
        open(tmp_file, 'w') do |file|
          file.write( json_data )
        end unless ::Date.today == ::Date.parse(actual_day.to_s)
      end

      return raw_data
    end

    def fetch_companies(release: 'mitaka', metric: 'commits', companies: [])
      company_labels = []
      company_map = {}
      companies.each do |company|
        raw_data = fetch_company(
          release: release,
          company: company,
          target: 'companies',
          interval: 1,
          metric: metric,
        )
        company_labels = raw_data.keys
        series = []
        raw_data.each do |_, v|
          if v['stats'][0]
            series << v['stats'][0]['metric']
          else
            series << 0
          end
        end
        company_map[company] = series
      end

      company_labels = company_labels.map { |k| k.strftime("%Y/%m/%d")  }
      return [company_labels, company_map]
    end

    def fetch_engineers(release: 'mitaka', metric: 'commits', company: 'NEC')
      raw_data = fetch_company(
        release: release,
        company: company,
        target: 'engineers',
        interval: 7,
        metric: metric,
        flag: :friday
      )

      person_labels = []
      person_map = {}
      empty_data = []

      raw_data.each do |k, v|
        person_labels << k.strftime("%Y/%m/%d")
        v = v['stats']
        v.each do |person|
          id = person['id']
          metric = person['metric'].to_i
          person_map[id] = empty_data.dup unless person_map[id]
          person_map[id] << metric
        end
        empty_data << 0
      end

      person_map = person_map.sort_by{|_, v| - v.last }.to_h

      return [person_labels, person_map]
    end

  end
end
