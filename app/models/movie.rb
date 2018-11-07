class Movie < ApplicationRecord
  has_many :rentals

  validates :title, presence: true
  validates :inventory, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :available_inventory, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def check_in
    updated_available_inventory = self.available_inventory + 1
    self.update(available_inventory: updated_available_inventory)
  end

  def check_out
    updated_available_inventory = self.available_inventory - 1
    self.update(available_inventory: updated_available_inventory)
  end
end
