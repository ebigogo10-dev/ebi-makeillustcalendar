class AddTemplateToCalendars < ActiveRecord::Migration[6.1]
  def change
    add_column :calendars, :template, :boolean
  end
end
