class CreateLogos < ActiveRecord::Migration[6.1]
  def change
    create_table :logos do |t|
    t.references :user
    t.string :images
    end
  end
end
