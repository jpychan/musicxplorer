class Festival < ActiveRecord::Base
  has_many :festival_genres
  has_many :genres, through: :festival_genres

  validates :name, presence: true, uniqueness: true
  
end