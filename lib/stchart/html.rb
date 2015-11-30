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
  end
end
