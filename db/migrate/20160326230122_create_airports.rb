class CreateAirports < ActiveRecord::Migration
  def change
    create_table :airports do |t|
      t.string :name
      t.float :latitude
      t.float :longitude
      t.string :city
      t.string :country
      t.string :iata_code

      t.timestamps null: false
    end
  end
end
