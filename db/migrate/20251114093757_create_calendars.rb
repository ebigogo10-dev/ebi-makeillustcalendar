class CreateCalendars < ActiveRecord::Migration[6.1]
  def change
    create_table :calendars do |t|
      t.references :user
      t.string :calendar_name
      t.string :calendar_type
      t.date :start_day
      t.date :end_day
      t.text :calendar_info
    end
  end
end
