class Movie < ApplicationRecord
  has_many :rentals

  validates :title, presence: true
end
