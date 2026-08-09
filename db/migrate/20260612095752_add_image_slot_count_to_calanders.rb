class AddImageSlotCountToCalanders < ActiveRecord::Migration[7.2]
  def change
    add_column :calendars, :image_slot_count, :integer, default: 1
  end
end
