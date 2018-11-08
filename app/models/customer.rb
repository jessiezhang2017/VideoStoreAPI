class Customer < ApplicationRecord
  has_many :rentals
  has_many :movies, through: :rentals
  
  validates :name, presence: true
  validates :movies_checked_out_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def self.sort?(input)
    valid_fields = ["name", "registered_at", "postal_code" ]
    if valid_fields.include? (input)
      return true
    else
      return false
    end
  end

  def check_out
    checked_out_count = self.movies_checked_out_count + 1
    self.update(movies_checked_out_count: checked_out_count)
  end

  def check_in
    checked_out_count = self.movies_checked_out_count - 1
    self.update(movies_checked_out_count: checked_out_count)
  end

end
