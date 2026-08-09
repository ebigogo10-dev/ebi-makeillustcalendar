class AddDisplayToCalendars < ActiveRecord::Migration[6.1]
  def change
    add_column :calendars, :display, :string
  end
end
