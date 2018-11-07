class Rental < ApplicationRecord
  STATUSES = ["checked out", "returned"]

  belongs_to :customer
  belongs_to :movie

  validates :check_out_date, presence: true
  validates :due_date, presence: true
  validates :status,  presence: true, inclusion: { in: STATUSES }

  def self.check_out(customer_id, movie_id)
    rental = Rental.new(customer_id: customer_id, movie_id: movie_id)
    rental.check_out_date = Date.today
    rental.due_date = rental.check_out_date + 7
    return rental
  end

  def check_in
    self.customer.check_in
    self.movie.check_in
    self.update(status: "returned")
  end

end
