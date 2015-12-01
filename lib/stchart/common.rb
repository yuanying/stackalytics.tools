module Stchart
  module Common
    def _short_id(id)
      id.split('@')[0]
    end

    def _zip_commit_number(metric_size, person_map)
      metrics = []
      metric_size.times do |i|
        person_map.each do |_, v|
          metrics[i] ||= 0
          metrics[i] += v[i]
        end
      end
      return metrics
    end

    def _zip_people_number(metric_size, person_map)
      metrics = []
      metric_size.times do |i|
        person_map.each do |_, v|
          metrics[i] ||= 0
          metrics[i] += 1 if v[i] != 0
        end
      end
      return metrics
    end
  end

  ROOT = File.join( File.dirname(__FILE__), '..', '..' )

  COLORS = [
    ["rgba(75, 178, 197, 1)", "rgba(75, 178, 197, 0.2)"],
    ["rgba(234, 162, 40, 1)", "rgba(234, 162, 40, 0.2)"],
    ["rgba(197, 180, 127, 1)", "rgba(197, 180, 127, 0.2)"],
    ["rgba(87, 149, 117, 1)", "rgba(87, 149, 117, 0.2)"],
    ["rgba(131, 149, 87, 1)", "rgba(131, 149, 87, 0.2)"],
    ["rgba(149, 140, 18, 1)", "rgba(149, 140, 18, 0.2)"],
    ["rgba(149, 53, 121, 1)", "rgba(149, 53, 121, 0.2)"],
    ["rgba(75, 93, 228, 1)", "rgba(75, 93, 228, 0.2)"],
    ["rgba(216, 184, 63, 1)", "rgba(216, 184, 63, 0.2)"],
    ["rgba(255, 88, 0, 1)", "rgba(255, 88, 0, 0.2)"],
  ]

  def get_color(index)
    unless COLORS[index]
      color = "#{rand(256)}, #{rand(256)}, #{rand(256)}"
      COLORS[index] = ["rgba(#{color}, 1)", "rgba(#{color}, 0.2)"]
    end
  end

  RELEASES = [
    [0, 'cactus', Date.new(2011, 4, 15)],
    [1, 'diablo', Date.new(2011, 9, 22)],
    [2, 'essex', Date.new(2012, 4, 5)],
    [3, 'folsom', Date.new(2012, 9, 27)],
    [4, 'grizzly', Date.new(2014, 4, 4)],
    [5, 'havana', Date.new(2013, 9, 17)],
    [6, 'icehouse', Date.new(2014, 4, 17)],
    [7, 'juno', Date.new(2014, 9, 16)],
    [8, 'kilo', Date.new(2015, 4, 30)],
    [9, 'liberty', Date.new(2015, 9, 17)],
    [10, 'mitaka', Date.new(2016, 4, 8)],
  ]
end
