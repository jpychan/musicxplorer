class Festival < ActiveRecord::Base
  has_many :performances
  has_many :artists, through: :performances
  has_many :festival_genres
  has_many :genres, through: :festival_genres

  validates :name, presence: true
end 