class Presenter
  TABLE_TITLES = {
    'full-novice-1' => 'Full Novice 1'
  }

  def self.table_title(plan)
    TABLE_TITLES[plan]
  end
end
