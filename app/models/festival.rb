class Festival < ActiveRecord::Base
  has_many :performances
  has_many :artists, through: :performances

  validates :name, presence: true
  
end