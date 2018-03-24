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
  calendar = params['calendar']

  plan = Plan.new(plan_name, racedate, calendar)

  return erb :index, :locals => {
    :week_header => plan.header,
    :rows => plan.rows,
    :table_title => plan.table_title,
    :racedate => params['racedate'] || '',
    :plan => plan.plan_name,
    :plan_titles => Plan::TABLE_TITLES
  } unless csv

  headers "Content-Disposition" => "attachment;#{plan.filename}.csv", "Content-Type" => "application/octet-stream"

  plan.generate_csv
end
