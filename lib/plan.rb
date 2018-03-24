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

  TRAINING_TABLE_SELECTOR = '//table/tbody/tr'

  DEFAULT_NAME = 'full-novice-1'

  DETAILS = {
    'full-novice-1' => {
      'url' => 'http://www.halhigdon.com/training/51137/Marathon-Novice-1-Training-Program',
      'table_title' => 'Full Novice 1'
    },
    'full-novice-2' => {
      'url' => 'http://www.halhigdon.com/training/51138/Marathon-Novice-2-Training-Program',
      'table_title' => 'Full Novice 2'
    },
    'full-intermediate-1' => {
      'url' => 'http://www.halhigdon.com/training/51139/Marathon-Intermediate-1-Training-Program',
      'table_title' => 'Full Intermediate 1'
    },
    'full-intermediate-2' => {
      'url' => 'http://www.halhigdon.com/training/51140/Marathon-Intermediate-2-Training-Program',
      'table_title' => 'Full Intermediate 2'
    },
    'full-advanced-1' => {
      'url' => 'http://www.halhigdon.com/training/51141/Marathon-Advanced-1-Training-Program',
      'table_title' => 'Full Advanced 1'
    },
    'full-advanced-2' => {
      'url' => 'http://www.halhigdon.com/training/51142/Marathon-Advanced-2-Training-Program',
      'table_title' => 'Full Advanced 2'
    },
    'full-personalbest' => {
      'url' => 'http://www.halhigdon.com/training/51150/Marathon-Personal-Best-Training-Program',
      'table_title' => 'Full Personal Best'
    },
    'full-marathon-3' => {
      'url' => 'http://www.halhigdon.com/training/51151/Marathon-Marathon-3-Training-Program',
      'table_title' => 'Full Marathon 3'
    },
    'full-senior' => {
      'url' => 'http://www.halhigdon.com/training/51231/Marathon-Senior-Training-Program',
      'table_title' => 'Full Senior'
    },
    'full-ultra-50' => {
      'url' => 'http://halhigdon.com/training/67146/Ultramarathon-50-K',
      'table_title' => 'Full Ultra 50K'
    },
    'full-boston' => {
      'url' => 'http://halhigdon.com/training/51230/Marathon-Boston-Bound-Training-Program',
      'table_title' => 'Full Boston Bound'
    },
    'full-dopey' => {
      'url' => 'http://www.halhigdon.com/writing/57107/Dopey%20Challenge%20Training%20Guide',
      'table_title' => 'Full Dopey Challenge'
    },
    'half-novice-1' => {
      'url' => 'http://www.halhigdon.com/training/51131/Half-Marathon-Novice-1-Training-Program',
      'table_title' => 'Half Novice 1'
    },
    'half-novice-2' => {
      'url' => 'http://www.halhigdon.com/training/51312/Half-Marathon-Novice-2-Training-Program',
      'table_title' => 'Half Novice 2'
    },
    'half-interm-1' => {
      'url' => 'http://www.halhigdon.com/training/64474/Half-Marathon-Walk-Training-Program-Intermediate-1',
      'table_title' => 'Half Intermediate 1'
    },
    'half-interm-2' => {
      'url' => 'http://www.halhigdon.com/training/64471/Half-Marathon-Walk-Training-Program-Intermediate-2',
      'table_title' => 'Half Intermediate 2'
    },
    'half-advanced' => {
      'url' => 'http://www.halhigdon.com/training/51133/Half-Marathon-Advanced-Training-Program',
      'table_title' => 'Half Advanced'
    },
    'half-hm3' => {
      'url' => 'http://www.halhigdon.com/training/64492/Half-Marathon-Walk-Training-Program-HM3',
      'table_title' => 'Half HM3'
    },
    'half-walk' => {
      'url' => 'http://www.halhigdon.com/training/51134/Half-Marathon-Walk-Training-Program',
      'table_title' => 'Half Walk'
    }
  }

  ALL_DAY_EVENT = true
  START_TIME = ""
  END_TIME = ""
  LOCATION = ""
  DESCRIPTION = ""

  def initialize(plan_name, racedate, calendar)
    @plan_name = plan_name
    @racedate = racedate
    @calendar = calendar

    header, rows = get_table_data(racedate, plan_name)
    @header = header
    @rows = rows
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

  def plan_url(plan = DEFAUL_NAME)
    DETAILS[plan]['url']
  end

  def get_table_data(racedate, plan)
    url = plan_url(plan)
    return get_table_data_by_racedate(racedate, url) if racedate
    get_original_table_data(url)
  end

  def get_original_table_data(url)
    doc = Nokogiri::HTML(open(url))

    rows = []

    doc.xpath(TRAINING_TABLE_SELECTOR).each do |row|
      tarray = []

      row.xpath('td').each do |cell|
        tarray << cell.text
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

    doc.xpath(TRAINING_TABLE_SELECTOR).each_with_index do |row, i|
      next if i == 0 # skip header

      tarray = []

      tarray << training_date.strftime("%m/%d/%Y")

      row.xpath('td').each_with_index do |cell, j|
        next if j == 0 # skip week numbers
        tarray << cell.text
      end

      training_date += 7 unless tarray.empty? # if is empty, was header row so don't increment training_date

      rows << tarray
    end

    [choose_week_header(start_date.wday), rows]
  end

  def table_title
    DETAILS[@plan_name]['table_title']
  end

  def filename
    return "#{@plan_name}-cal-#{@racedate}" if @racedate && @calendar
    return "#{@plan_name}-#{@racedate}" if @racedate
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

      doc.xpath(TRAINING_TABLE_SELECTOR).each_with_index do |row, i|
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

    doc.xpath(TRAINING_TABLE_SELECTOR).each_with_index do |row, i|
      next if i == 0 # skip headers

      num_weeks += 1
    end

    num_training_days = (num_weeks) * 7 - 1 # mult by num days in week, off by one because of raceday

    racedate - num_training_days
  end
end
