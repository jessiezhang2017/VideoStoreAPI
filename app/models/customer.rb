class Customer < ApplicationRecord
  has_many :rentals

  validates :name, presence: true

  validates :movies_checked_out_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def check_out
    checked_out_count = self.movies_checked_out_count + 1
    self.update(movies_checked_out_count: checked_out_count)
  end

  def check_in
    checked_out_count = self.movies_checked_out_count - 1
    self.update(movies_checked_out_count: checked_out_count)
  end
end
