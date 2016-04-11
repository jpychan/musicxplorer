class AddFestivals < ActiveRecord::Migration
  def change
    create_table :festivals do |t|
      t.string :name
      t.float :latitude
      t.float :longitude
      t.date :start_date
      t.date :end_date
      t.string :date
      t.string :location
      t.string :city
      t.string :state
      t.string :country
      t.string :website
      t.text :description
      t.integer :price
      t.string :camping
      t.timestamps null: false
    end

    create_table :artists do |t|
      t.string :name
      t.timestamps null: false
    end

    create_table :performances do |t|
      t.references :festival
      t.references :artist
      t.timestamps null: false
    end

    create_table :genres do |t|
      t.string :name
      t.timestamps null: false
    end

    create_table :festival_genres do |t|
      t.references :genre, index: true
      t.references :festival, index: true
      t.timestamps null: false
    end
  end
end
