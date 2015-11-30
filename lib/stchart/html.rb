require 'stchart/common'

module Stchart
  module Html
    def html_generate(html_path, company, person_labels, person_map, colors: Stchart::COLORS)
      open(html_path, 'w') do |io|
        open(File.join(File.dirname(__FILE__), 'assets', 'template.html.erb')) do |t|
          io.write(ERB.new(t.read).result(binding))
        end
      end
    end

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

    def html_companies_compare(html_path, person_labels, person_maps, colors: Stchart::COLORS)
      person_maps = person_maps.inject( {} ) do |a, (k,v)|
        a[k] ||= {}
        a[k]['commit'] = _zip_commit_number(person_labels.size, v)
        a[k]['people'] = _zip_people_number(person_labels.size, v)
        a
      end
      open(html_path, 'w') do |io|
        open(File.join(File.dirname(__FILE__), 'assets', 'companies.html.erb')) do |t|
          io.write(ERB.new(t.read).result(binding))
        end
      end
    end
  end
end
