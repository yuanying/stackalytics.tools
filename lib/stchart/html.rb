require 'stchart/common'
require 'stchart/color'
require 'stchart/date'

module Stchart
  module Html
    include Color
    include Date
    include Common

    def html_generate(
      html_path,
      company,
      commits_labels,
      commits_data,
      reviews_labels,
      reviews_data
    )
      open(html_path, 'w') do |io|
        open(File.join(File.dirname(__FILE__), 'assets', 'template.html.erb')) do |t|
          io.write(ERB.new(t.read).result(binding))
        end
      end
    end

    def html_companies_compare(
      html_path,
      person_labels,
      person_maps,
      commits_labels,
      commits_data,
      reviews_labels,
      reviews_data
    )
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
