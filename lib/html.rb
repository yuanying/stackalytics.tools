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

def html_generate(html_path, person_labels, person_map, colors: COLORS)
  open(html_path, 'w') do |io|
    open(File.join(File.dirname(__FILE__), 'assets', 'template.html.erb')) do |t|
      io.write(ERB.new(t.read).result(binding))
    end
  end
end
