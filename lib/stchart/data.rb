require 'stchart/common'

module Stchart
  module Data
    def fetch_company(release: 'mitaka', company: 'NEC')
      base_uri = "http://stackalytics.com/api/1.0/stats/engineers?release=#{release}&metric=commits&company=#{company}"

      release = Stchart::RELEASES.find{|v| v[1] == release }
      release_begin_date = Stchart::RELEASES[release[0] - 1][2]
      release_date = release[2]

      tmp_dir = File.join(Stchart::ROOT, '.tmp', company)
      FileUtils.mkdir_p(tmp_dir)

      raw_data = {}

      day = release_begin_date + 7.days
      while day < Time.now && day < release_date
        tmp_file = File.join(tmp_dir, day.to_i.to_s)
        if File.file?(tmp_file)
          data_uri = tmp_file
        else
          data_uri = "#{base_uri}&end_date=#{day.to_i}"
        end
        json_data = nil
        open(data_uri) do |io|
          json_data = io.read
          raw_data[day] = JSON.parse( json_data )
        end
        open(tmp_file, 'w') do |file|
          file.write( json_data )
        end
        day = day + 7.days
      end

      person_labels = []
      person_map = {}
      empty_data = []

      raw_data.each do |k, v|
        person_labels << k.strftime("%y/%m/%d")
        v = v['stats']
        v.each do |person|
          id = person['id'].split('@')[0]
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
