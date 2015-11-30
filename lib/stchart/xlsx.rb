require 'axlsx'

require 'stchart/common'

module Stchart
  module Xlsx
    def xlsx_generate(xlsx_path, company, person_labels, person_map, colors: Stchart::COLORS)
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(:name => "Index") do |sheet|
          sheet.add_row(person_labels.dup.unshift(''))
          person_map.each do |id, metric|
            sheet.add_row([id] + metric)
          end
          chart_y = person_map.size + 1

          # row_label_end =
          sheet.add_chart(Axlsx::LineChart,
                          start_at: [0, chart_y + 1],
                          end_at: [person_labels.size, chart_y * 3],
                          rotX: 0, rotY: 0) do |chart|
            chart.title = company
            col_label_begin = Axlsx.col_ref(1)
            col_label_end   = Axlsx.col_ref(person_labels.size)
            chart.show_legend = true
            person_map.each_with_index do |_, index|
              chart.add_series data: sheet["#{col_label_begin}#{index + 2}:#{col_label_end}#{index + 2}"],
                               labels: sheet["#{col_label_begin}1:#{col_label_end}1"],
                               title: sheet["A#{index + 2}"],
                               smooth: false
            end
          end
        end
        package.serialize(xlsx_path)
      end
    end
  end
end
