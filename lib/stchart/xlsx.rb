require 'axlsx'

require 'stchart/common'

module Stchart
  module Xlsx
    include Common

    def add_sheet_for_engeneer(package, name, company, labels, data)
      package.workbook.add_worksheet(:name => name) do |sheet|
        sheet.add_row(labels.dup.unshift(''))
        data.each do |id, metric|
          sheet.add_row([id] + metric)
        end
        chart_y = data.size + 1

        # row_label_end =
        sheet.add_chart(Axlsx::LineChart,
                        start_at: [0, chart_y + 1],
                        end_at: [labels.size, chart_y * 3],
                        rotX: 0, rotY: 0) do |chart|
          chart.title = company
          col_label_begin = Axlsx.col_ref(1)
          col_label_end   = Axlsx.col_ref(labels.size)
          chart.show_legend = true
          data.each_with_index do |_, index|
            chart.add_series data: sheet["#{col_label_begin}#{index + 2}:#{col_label_end}#{index + 2}"],
                             labels: sheet["#{col_label_begin}1:#{col_label_end}1"],
                             title: sheet["A#{index + 2}"],
                             smooth: false
          end
        end
      end
    end

    def xlsx_generate(
          xlsx_path,
          company,
          commits_labels,
          commits_data,
          reviews_labels,
          reviews_data
        )
      Axlsx::Package.new do |package|
        add_sheet_for_engeneer(package, 'Commits', company, commits_labels, commits_data)
        add_sheet_for_engeneer(package, 'Reviews', company, reviews_labels, reviews_data)
        package.serialize(xlsx_path)
      end
    end

    def xlsx_companies_compare(
      xlsx_path,
      person_labels,
      person_maps,
      company_labels,
      company_maps)
      person_maps = person_maps.inject( {} ) do |a, (k,v)|
        a[k] ||= {}
        a[k]['commit'] = _zip_commit_number(person_labels.size, v)
        a[k]['people'] = _zip_people_number(person_labels.size, v)
        a
      end

      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(:name => "Commits (1)") do |sheet|
          sheet.add_row(person_labels.dup.unshift(''))
          person_maps.each do |id, metric|
            sheet.add_row([id] + metric['commit'])
          end
        end

        package.workbook.add_worksheet(:name => "Commits (2)") do |sheet|
          sheet.add_row(company_labels.dup.unshift(''))
          company_maps.each do |id, metric|
            sheet.add_row([id] + metric)
          end
        end

        package.workbook.add_worksheet(:name => "Peaple") do |sheet|
          sheet.add_row(person_labels.dup.unshift(''))
          person_maps.each do |id, metric|
            sheet.add_row([id] + metric['people'])
          end
        end
        package.serialize(xlsx_path)
      end
    end
  end
end
