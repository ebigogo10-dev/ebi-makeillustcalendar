class AddColorToCalendars < ActiveRecord::Migration[6.1]
  def change
      add_column :calendars, :color, :string
  end
end
