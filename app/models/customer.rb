class Customer < ApplicationRecord
  has_many :rentals

  validates :name, presence: true

  validates :movies_checked_out_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

end
