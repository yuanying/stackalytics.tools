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
  html_commits_path = File.join(ROOT, "#{company}.commits.html")
  html_reviews_path = File.join(ROOT, "#{company}.reviews.html")
  xlsx_path = File.join(ROOT, "#{company}.xlsx")

  commits_labels, commits_data = fetch_engineers(
    release: release,
    company: company,
    metric: 'commits',
  )
  html_engineer_generate(
    html_commits_path,
    company,
    'commits',
    commits_labels,
    commits_data
  )
  reviews_labels, reviews_data = fetch_engineers(
    release: release,
    company: company,
    metric: 'marks',
  )
  html_engineer_generate(
    html_reviews_path,
    company,
    'reviews',
    reviews_labels,
    reviews_data
  )

  html_generate(
    html_path,
    company,
    commits_labels,
    commits_data,
    reviews_labels,
    reviews_data,
  )
  xlsx_generate(
    xlsx_path,
    company,
    commits_labels,
    commits_data,
    reviews_labels,
    reviews_data,
  )

  person_labels = commits_labels
  person_maps[company] = commits_data
end

commits_labels, commits_data = fetch_companies(
  release: release,
  companies: companies,
  metric: 'commits'
)
reviews_labels, reviews_data = fetch_companies(
  release: release,
  companies: companies,
  metric: 'marks'
)

html_path = File.join(ROOT, "index.html")
html_companies_compare(
  html_path,
  person_labels,
  person_maps,
  commits_labels,
  commits_data,
  reviews_labels,
  reviews_data
)
xlsx_path = File.join(ROOT, "index.xlsx")
xlsx_companies_compare(
  xlsx_path,
  person_labels,
  person_maps,
  commits_labels,
  commits_data,
  reviews_labels,
  reviews_data
)
