class Genre < ActiveRecord::Base
  has_many :festival_genres
  has_many :festivals, through: :festival_genres

  validates :genre_type, presence: true, uniqueness: true, length: { in: 6..30 }
end