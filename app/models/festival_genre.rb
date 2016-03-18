class FestivalGenre < ActiveRecord::Base

  belongs_to :festival
  belongs_to :genre_1, class_name: "Genre",
                        foreign_key: "genre_1_id"
  belongs_to :genre_2, class_name: "Genre",
                        foreign_key: "genre_2_id"
  belongs_to :genre_3, class_name: "Genre",
                        foreign_key: "genre_3_id"
  belongs_to :genre_4, class_name: "Genre",
                        foreign_key: "genre_4_id"

  validates :festival, presence: true, uniqueness: true
  validates :genre_1, presence: true

end