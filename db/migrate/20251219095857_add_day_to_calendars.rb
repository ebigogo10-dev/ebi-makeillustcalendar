class AddDayToCalendars < ActiveRecord::Migration[6.1]
  def change
    add_column :calendars, :day, :date
  end
end
