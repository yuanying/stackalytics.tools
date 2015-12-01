#!/usr/bin/env ruby -wKU
require 'active_support'
require 'active_support/core_ext'
require 'open-uri'
require 'json'
require 'yaml'
require 'optparse'
require 'fileutils'

companies = []
release = "mitaka"

opt = OptionParser.new
opt.on('-c', '--company [VAL]') {|v| companies << v }
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

person_labels = []
person_maps = {}
companies.each do |company|
  html_path = File.join(ROOT, "#{company}.html")
  xlsx_path = File.join(ROOT, "#{company}.xlsx")

  person_labels, person_map = fetch_engineers(release: release, company: company)
  html_generate(html_path, company, person_labels, person_map)
  xlsx_generate(xlsx_path, company, person_labels, person_map)

  person_maps[company] = person_map
end

company_labels, company_maps = fetch_companies(release: release, companies: companies)

html_path = File.join(ROOT, "index.html")
html_companies_compare(
  html_path,
  person_labels,
  person_maps,
  company_labels,
  company_maps
)
xlsx_path = File.join(ROOT, "index.xlsx")
xlsx_companies_compare(
  xlsx_path,
  person_labels,
  person_maps,
  company_labels,
  company_maps
)
