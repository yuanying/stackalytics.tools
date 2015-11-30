#!/usr/bin/env ruby -wKU
require 'active_support'
require 'active_support/core_ext'
require 'open-uri'
require 'json'
require 'yaml'
require 'optparse'
require 'fileutils'

company = "NEC"
release = "mitaka"

opt = OptionParser.new
opt.on('-c', '--company') {|v| company = v }
opt.on('-r', '--release') {|v| release = v }
opt.parse!(ARGV)

base_uri = "http://stackalytics.com/api/1.0/stats/engineers?release=#{release}&metric=commits&company=#{company}"

releases = [
  [0, 'cactus', Time.new(2011, 4, 15)],
  [1, 'diablo', Time.new(2011, 9, 22)],
  [2, 'essex', Time.new(2012, 4, 5)],
  [3, 'folsom', Time.new(2012, 9, 27)],
  [4, 'grizzly', Time.new(2014, 4, 4)],
  [5, 'havana', Time.new(2013, 9, 17)],
  [6, 'icehouse', Time.new(2014, 4, 17)],
  [7, 'juno', Time.new(2014, 9, 16)],
  [8, 'kilo', Time.new(2015, 4, 30)],
  [9, 'liberty', Time.new(2015, 9, 17)],
  [10, 'mitaka', Time.new(2016, 4, 8)],
]

release = releases.find{|v| v[1] == release }
release_begin_date = releases[release[0] - 1][2]
release_date = release[2]

ROOT = File.dirname(__FILE__)
tmp_dir = File.join(ROOT, '.tmp', company)
FileUtils.mkdir_p(tmp_dir)

$:.unshift(File.join(ROOT, 'lib'))

require 'html'

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

html_path = File.join(ROOT, 'index.html')

html_generate(html_path, person_labels, person_map)
