class Genre < ActiveRecord::Base
  has_many :festival_genres
  has_many :festivals, through: :festival_genres

  validates :name, presence: true, uniqueness: true, length: { in: 3..20 }
end
