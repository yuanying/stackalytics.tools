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
opt.on('-c', '--company [VAL]') {|v| company = v }
opt.on('-r', '--release [VAL]') {|v| release = v }
opt.parse!(ARGV)

ROOT = File.dirname(__FILE__)
$:.unshift(File.join(ROOT, 'lib'))

require 'stchart/data'
require 'stchart/html'
require 'stchart/xlsx'
include Stchart::Data
include Stchart::Html
include Stchart::Xlsx

html_path = File.join(ROOT, 'index.html')
xlsx_path = File.join(ROOT, 'index.xlsx')

person_labels, person_map = fetch(release: release, company: company)
html_generate(html_path, company, person_labels, person_map)
xlsx_generate(xlsx_path, company, person_labels, person_map)
