require 'sinatra'
require 'open-uri'
require 'nokogiri'
require 'csv'
require './lib/plan'

get '/' do
  redirect '/full-novice-1'
end

get '/:plan' do
  csv = params['csv']
  plan_name = params['plan']
  racedate = params['racedate'] && Date.strptime(params['racedate'], '%Y-%m-%d')

  plan = Plan.new(plan_name, racedate)

  return erb :index, :locals => {week_header: plan.header, :rows => plan.rows, :table_title => plan.table_title, :racedate => params['racedate'] || ''} unless csv

  headers "Content-Disposition" => "attachment;full-novice-1.csv", "Content-Type" => "application/octet-stream"

  plan.generate_table_csv
end

get '/:plan/calendar_csv' do
  plan = params['plan']
  racedate = Date.strptime(params['racedate'], '%Y-%m-%d')

  headers "Content-Disposition" => "attachment;full-novice-1-cal-#{racedate}.csv", "Content-Type" => "application/octet-stream"

  Helper.generate_google_cal_csv(racedate, plan)
end
