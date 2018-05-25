class Plan
  GOOGLE_CAL_HEADER = ["Subject", "Start Date", "All Day Event", "Start Time", "End Time", "Location", "Description"]

  WEEK_HEADER = ["Week", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun"]

  WEEK_STARTING_HEADERS = {
    0 => ["Week starting", "Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"],
    1 => ["Week starting", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun"],
    2 => ["Week starting", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun", "Mon"],
    3 => ["Week starting", "Wed", "Thurs", "Fri", "Sat", "Sun", "Mon", "Tues"],
    4 => ["Week starting", "Thurs", "Fri", "Sat", "Sun", "Mon", "Tues", "Wed"],
    5 => ["Week starting", "Fri", "Sat", "Sun", "Mon", "Tues", "Wed", "Thurs"],
    6 => ["Week starting", "Sat", "Sun", "Mon", "Tues", "Wed", "Thurs", "Fri"]
  }

  TABLE_SELECTOR = '//table/tbody/tr'

  DEFAULT_NAME = 'novice_1_marathon'

  URLS = %w(
    https://www.halhigdon.com/training-programs/marathon-training/novice-1-marathon
    https://www.halhigdon.com/training-programs/marathon-training/novice-2-marathon
    http://www.halhigdon.com/training/51139/Marathon-Intermediate-1-Training-Program
    http://www.halhigdon.com/training/51140/Marathon-Intermediate-2-Training-Program
    http://www.halhigdon.com/training/51141/Marathon-Advanced-1-Training-Program
    http://www.halhigdon.com/training/51142/Marathon-Advanced-2-Training-Program
    http://www.halhigdon.com/training/51150/Marathon-Personal-Best-Training-Program
    http://www.halhigdon.com/training/51151/Marathon-Marathon-3-Training-Program
    http://www.halhigdon.com/training/51231/Marathon-Senior-Training-Program
    http://halhigdon.com/training/67146/Ultramarathon-50-K
    http://halhigdon.com/training/51230/Marathon-Boston-Bound-Training-Program
    http://www.halhigdon.com/writing/57107/Dopey%20Challenge%20Training%20Guide
    http://www.halhigdon.com/training/51131/Half-Marathon-Novice-1-Training-Program
    http://www.halhigdon.com/training/51312/Half-Marathon-Novice-2-Training-Program
    http://www.halhigdon.com/training/64474/Half-Marathon-Walk-Training-Program-Intermediate-1
    http://www.halhigdon.com/training/64471/Half-Marathon-Walk-Training-Program-Intermediate-2
    http://www.halhigdon.com/training/51133/Half-Marathon-Advanced-Training-Program
    http://www.halhigdon.com/training/64492/Half-Marathon-Walk-Training-Program-HM3
    http://www.halhigdon.com/training/51134/Half-Marathon-Walk-Training-Program
    http://www.halhigdon.com/training/50933/5K-Novice-Training-Program
    http://www.halhigdon.com/training/50934/5K-Intermediate-Training-Program
    http://www.halhigdon.com/training/50935/5K-Advanced-Training-Program
    http://www.halhigdon.com/training/50936/5K-Walk-Training-Program
    http://www.halhigdon.com/training/51096/8K-Novice-Training-Program
    http://www.halhigdon.com/training/51097/8K-Intermediate-Training-Program
    http://www.halhigdon.com/training/51098/8K-Advanced-Training-Program
    http://www.halhigdon.com/training/51122/10K-Novice-Training-Program
    http://www.halhigdon.com/training/51123/10K-Intermediate-Training-Program
    http://www.halhigdon.com/training/51124/10K-Advanced-Training-Program
    http://www.halhigdon.com/training/51125/10K-Walk-Training-Program
    http://www.halhigdon.com/training/51127/15K-10-mile-Novice-Training-Program
    http://www.halhigdon.com/training/51128/15K-10-mile-Intermediate-Training-Program
    http://www.halhigdon.com/training/51129/15K-10-mile-Advanced-Training-Program
    http://www.halhigdon.com/training/51127/15K-10-mile-Novice-Training-Program
    http://www.halhigdon.com/training/51128/15K-10-mile-Intermediate-Training-Program
    http://www.halhigdon.com/training/51129/15K-10-mile-Advanced-Training-Program
  )

  ALL_DAY_EVENT = true
  START_TIME = ""
  END_TIME = ""
  LOCATION = ""
  DESCRIPTION = ""

  def self.all_plan_details
    URLS.map do |url|
      plan = url.split('/').last

      [
        plan.gsub('-', '_').gsub('%20', '_').downcase,
        {
          'url' => url,
          'table_title' => plan.gsub('-', ' ').gsub('%20', ' ')
        }
      ]
    end.to_h
  end

  def initialize(plan_name, racedate, calendar, grid_type = 'original')
    @plan_name = plan_name
    @racedate = racedate
    @calendar = calendar
    @grid_type = grid_type
    @start_date_string = racedate ? get_start_date_string(racedate, plan_name) : '' # this is kind of jank
    header, rows = get_table_data(racedate, plan_name)
    @header = header
    @rows = rows
  end

  def get_start_date_string(racedate, plan)
    url = plan_url(plan)
    doc = Nokogiri::HTML(open(url))
    start_date = get_start_date(racedate, doc)
    start_date.strftime("%Y/%m/%d")
  end

  def start_date_string
    @start_date_string
  end

  def all_plan_details
    @details ||= URLS.map do |url|
      plan = url.split('/').last

      [
        plan.gsub('-', '_').gsub('%20', '_').downcase,
        {
          'url' => url,
          'table_title' => plan.gsub('-', ' ').gsub('%20', ' ')
        }
      ]
    end.to_h
  end

  def header
    @header
  end

  def rows
    @rows
  end

  def plan_name
    @plan_name
  end

  def plan_url(plan = DEFAULT_NAME)
    all_plan_details[plan]['url']
  end

  def get_table_data(racedate, plan)
    url = plan_url(plan)
    return get_table_data_by_racedate(racedate, url) if @grid_type == 'racedate'
    get_original_table_data(url)
  end

  def get_original_table_data(url)
    doc = Nokogiri::HTML(open(url))

    rows = []

    doc.xpath(TABLE_SELECTOR).each do |row|
      tarray = []
      catch :invalidrow do
        row.xpath('td').each_with_index do |cell, i|
          throw :invalidrow if i == 0 && !cell.text.is_i? # row does not begin with week number
          tarray << cell.text
        end
      end
      rows << tarray
    end

    [WEEK_HEADER, rows]
  end

  def get_table_data_by_racedate(racedate, url)
    doc = Nokogiri::HTML(open(url))

    rows = []

    start_date = get_start_date(racedate, doc)

    training_date = start_date

    doc.xpath(TABLE_SELECTOR).each_with_index do |row, i|
      next if i == 0 # skip header

      tarray = []

      catch :invalidrow do
        row.xpath('td').each_with_index do |cell, j|
          throw :invalidrow if j == 0 && !cell.text.is_i? # row does not begin with week number
          if j == 0 # add training date in place of week numbers
            tarray << training_date.strftime("%m/%d/%Y")
            next
          end
          tarray << cell.text
        end
      end

      training_date += 7 unless tarray.empty? # if is empty, was header row so don't increment training_date

      rows << tarray
    end

    [choose_week_header(start_date.wday), rows]
  end

  def calendar_events
    url = plan_url(@plan_name)

    doc = Nokogiri::HTML(open(url))

    rows = []

    start_date = get_start_date(@racedate, doc)

    training_date = start_date
    events = []

    doc.xpath(TABLE_SELECTOR).each_with_index do |row, i|
      next if i == 0 # skip header

      catch :invalidrow do
        row.xpath('td').each_with_index do |cell, j|
          throw :invalidrow if j == 0 && !cell.text.is_i? # row does not begin with week number
          next if j == 0 # skip week numbers
          events << { 'title'  => cell.text, 'start'  => training_date.strftime("%m/%d/%Y") }
          training_date += 1
        end
      end
    end

    events
  end

  def table_title
    all_plan_details[@plan_name]['table_title']
  end

  def filename
    return "#{@plan_name}-cal-#{@racedate}" if @grid_type=='racedate' && @calendar
    return "#{@plan_name}-#{@racedate}" if @grid_type=='racedate'
    @plan_name
  end

  def generate_csv
    return generate_table_csv unless @calendar
    generate_google_cal_csv
  end

  def generate_table_csv
    CSV.generate do |csv_string|
      csv_string << @header
      @rows.each do |row|
        csv_string << row
      end
    end
  end

  def generate_google_cal_csv
    url = plan_url(@plan_name)

    doc = Nokogiri::HTML(open(url))

    CSV.generate do |csv_string|
      csv_string << GOOGLE_CAL_HEADER
      training_date = get_start_date(@racedate, doc)

      doc.xpath(TABLE_SELECTOR).each_with_index do |row, i|
        next if i == 0 # skip headers

        row.xpath('td').each_with_index do |cell, j|
          next if j == 0 # skip first column which has week numbers
          csv_string << [cell, training_date, ALL_DAY_EVENT, START_TIME, END_TIME, LOCATION, DESCRIPTION]
          training_date += 1
        end
      end
    end
  end

  private

  def choose_week_header(weekday_int)
    WEEK_STARTING_HEADERS[weekday_int]
  end

  def get_start_date(racedate, doc)
    num_weeks = 0

    doc.xpath(TABLE_SELECTOR).each_with_index do |row, i|
      next if i == 0 # skip headers

      num_weeks += 1
    end

    num_training_days = (num_weeks) * 7 - 1 # mult by num days in week, off by one because of raceday

    racedate - num_training_days
  end
end

class String
  def is_i?
    self.to_i.to_s == self
  end
end
