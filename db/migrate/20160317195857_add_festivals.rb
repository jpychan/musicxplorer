class AddFestivals < ActiveRecord::Migration
  def change
    create_table :festivals do |t|
      t.string :name
      t.decimal :latitude
      t.decimal :longitude
      t.string :date
      # t.date :end_date
      t.string :location
      # t.string :city
      # t.string :state
      # t.string :country
      t.string :website
      t.text :description
      # t.text :artist_lineup
      t.integer :price
      # t.string :currency
      t.string :camping
      t.timestamps null: false
    end

    # create_table :artists do |t|
    #   t.references :festival
    #   t.string :name
    # end

    create_table :genres do |t|
      t.string :genre_type
      t.timestamps null: false
    end

    create_table :festival_genres do |t|
      t.references :festival
      t.references :genre
      t.references :genre_1
      t.references :genre_2
      t.references :genre_3
      t.references :genre_4
      t.timestamps null: false
    end

    # if Genre.all.empty?
    #   Genre.create(genre_type: 'Blues')
    #   Genre.create(genre_type: 'Country')
    #   Genre.create(genre_type: 'Dubstep')
    #   Genre.create(genre_type: 'Indie')
    #   Genre.create(genre_type: 'Jazz')
    #   Genre.create(genre_type: 'Misc')
    #   Genre.create(genre_type: 'Pop')
    #   Genre.create(genre_type: 'Rock')
    # end
  end
end
