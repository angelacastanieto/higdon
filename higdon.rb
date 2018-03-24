require 'sinatra'
require 'open-uri'
require 'nokogiri'
require 'csv'
require './lib/helper'

get '/' do
  redirect '/full-novice-1'
end

get '/:plan' do
  csv = params['csv']
  plan = params['plan']
  racedate = params['racedate'] && Date.strptime(params['racedate'], '%Y-%m-%d')

  header, rows = Helper.get_table_data(racedate, Helper.plan_url(plan))

  return erb :index, :locals => {week_header: header, :rows => rows, :table_title => 'Marathon Novice 1', :racedate => params['racedate'] || ''} unless csv

  headers "Content-Disposition" => "attachment;full-novice-1.csv", "Content-Type" => "application/octet-stream"

  Helper.generate_table_csv(header, rows)
end

get '/:plan/calendar_csv' do
  plan = params['plan']
  racedate = Date.strptime(params['racedate'], '%Y-%m-%d')

  headers "Content-Disposition" => "attachment;full-novice-1-cal-#{racedate}.csv", "Content-Type" => "application/octet-stream"

  Helper.generate_google_cal_csv(racedate, Helper.plan_url(plan))
end
