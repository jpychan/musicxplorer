class AddFestivals < ActiveRecord::Migration
  def change
    create_table :festivals do |t|
      t.string :name
      t.date :start_date
      t.date :end_date
      t.string :location
      t.string :city
      t.string :state
      t.string :country
      t.string :website
      t.text :description
      t.string :artist_lineup
      t.integer :price
      t.string :currency
      t.boolean :camping
      t.timestamps null: false
    end

    create_table :genres do |t|
      t.string :genre_type
      t.timestamps null: false
    end

    create_table :festival_genres do |t|
      t.references :festival
      t.references :genre_1
      t.references :genre_2
      t.references :genre_3
      t.references :genre_4
      t.timestamps null: false
    end

  end
end
