class ChangeFestivals < ActiveRecord::Migration
  def change
    change_table :festivals do |t|
      t.remove :end_date
      t.remove :city
      t.remove :state
      t.remove :country
      t.float :latitude
      t.float :longitude
      t.string :date
    end
    create_table :artists do |t|
      t.string :name
      t.timestamps null: false
    end
  end
end
