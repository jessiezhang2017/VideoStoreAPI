class Movie < ApplicationRecord
  has_many :rentals
  has_many :customers, through: :rentals

  validates :title, presence: true
  validates :inventory, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :available_inventory, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def self.sort?(input)
    valid_fields = ["title" ,"release_date"]
    if valid_fields.include? (input)
      return true
    else
      return false
    end
  end

end
