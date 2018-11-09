class Movie < ApplicationRecord
  has_many :rentals
  # has_many :customers, through: :rentals

  validates :title, presence: true, uniqueness: true
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


  def self.checked_out_rentals(movie)

    return movie.rentals.where("status = 'checked out'").map { |rental| { customer_id: rental.customer.id, customer_name: rental.customer.name, postal_code: rental.customer.postal_code, check_out_date: rental.check_out_date, due_date: rental.due_date } }

  end

  def self.returned_rentals(movie)
    return movie.rentals.where("status = 'returned'").map { |rental| { customer_id: rental.customer.id, customer_name: rental.customer.name, postal_code: rental.customer.postal_code, check_out_date: rental.check_out_date, due_date: rental.due_date } }

  end

  def check_out
    available_inventory_count = self.available_inventory - 1
    self.update(available_inventory: available_inventory_count)
  end

  def check_in
    checked_in_count = self.available_inventory + 1
    self.update(available_inventory: checked_in_count)
  end
end
