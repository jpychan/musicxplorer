class Artist < ActiveRecord::Base
  has_many :performances
  has_many :festivals, through: :performances
end
