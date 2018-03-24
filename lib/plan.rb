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

  DEFAULT_PLAN = 'full-novice-1'

  PLAN_URLS = {
    'full-novice-1' => 'http://www.halhigdon.com/training/51137/Marathon-Novice-1-Training-Program'
  }

  ALL_DAY_EVENT = true
  START_TIME = ""
  END_TIME = ""
  LOCATION = ""
  DESCRIPTION = ""

  TABLE_TITLES = {
    'full-novice-1' => 'Full Novice 1'
  }

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

  def plan_url(plan = DEFAULT_PLAN)
    PLAN_URLS[plan]
  end

  def get_table_data(racedate, plan)
    url = plan_url(plan)
    return get_table_data_by_racedate(racedate, url) if racedate
    get_original_table_data(url)
  end

  def get_original_table_data(url)
    doc = Nokogiri::HTML(open(url))

    rows = []

    doc.xpath('//table/tbody/tr').each do |row|
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

    doc.xpath('//table/tbody/tr').each_with_index do |row, i|
      next if i == 0 # skip header

      tarray = []

      tarray << training_date.strftime("%m/%d/%Y")

      row.xpath('td').each_with_index do |cell, j|
        next if j == 0 # skip week numberss
        tarray << cell.text
      end

      training_date += 7 unless tarray.empty? # if is empty, was header row so don't increment training_date

      rows << tarray
    end

    [choose_week_header(start_date.wday), rows]
  end

  def table_title
    TABLE_TITLES[@plan_name]
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

      doc.xpath('//table/tbody/tr').each_with_index do |row, i|
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

    doc.xpath('//table/tbody/tr').each_with_index do |row, i|
      next if i == 0 # skip headers

      num_weeks += 1
    end

    num_training_days = (num_weeks) * 7 - 1 # mult by num days in week, off by one because of raceday

    racedate - num_training_days
  end
end
