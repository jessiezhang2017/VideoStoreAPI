class Rental < ApplicationRecord
  STATUSES = ["checked out", "returned"]

  belongs_to :customer
  belongs_to :movie

  validates :check_out_date, presence: true
  validates :due_date, presence: true
  validates :status,  presence: true, inclusion: { in: STATUSES }

  def check_in
    checked_out_count = self.customer.movies_checked_out_count - 1
    self.customer.update(movies_checked_out_count: checked_out_count)
    updated_available_inventory = self.movie.available_inventory + 1
    self.movie.update(available_inventory: updated_available_inventory)
    self.update(status: "returned")
  end

  def self.check_out(customer_id, movie_id)
    rental = Rental.new(customer_id: customer_id, movie_id: movie_id)
    rental.check_out_date = Date.today
    rental.due_date = rental.check_out_date + 7
    return rental
  end

end
