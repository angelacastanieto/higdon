require 'sinatra'
require 'open-uri'
require 'nokogiri'
require 'csv'
require './lib/plan'
# TODO:
# add download by url in addition
# add separate race date set, and reset, so not always prompted for race date (only prompt if dont already have race date)

get '/' do
  redirect '/full-novice-1'
end

get '/:plan' do
  csv = params['csv']
  plan_name = params['plan']
  racedate = params['racedate'] && Date.strptime(params['racedate'], '%Y-%m-%d')
  calendar = params['calendar']

  plan = Plan.new(plan_name, racedate, calendar)

  return erb :index, :locals => {
    :week_header => plan.header,
    :rows => plan.rows,
    :table_title => plan.table_title,
    :racedate => params['racedate'] || '',
    :plan => plan.plan_name,
    :details => Plan::DETAILS
  } unless csv

  headers "Content-Disposition" => "attachment;#{plan.filename}.csv", "Content-Type" => "application/octet-stream"

  plan.generate_csv
end
