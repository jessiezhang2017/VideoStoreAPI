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

  def self.paginate_check(overdue_rentals, params_p, params_n)
    if params_p.nil? && params_n.nil?
      return overdue_rentals
    elsif params_p.nil? || params_n.nil?
      return "Both 'p' and 'n' must be present and a number to paginate. Please resubmit with valid parameters."
    elsif (params_p !~ /\D/) && (params_n !~ /\D/)
      return overdue_rentals.paginate(:page => params_p, :per_page => params_n)
    else
      return "Both 'p' and 'n' must be present and a number to paginate. Please resubmit with valid parameters."
    end
  end

  def self.sort_check(overdue_rentals, params_sort)
    valid_fields = ["title", "name", "checkout_date", "due_date"]
    if params_sort.nil?
      return overdue_rentals
    elsif valid_fields.include? (params_sort)
      return overdue_rentals.joins(:movie).order("movies.title") if params_sort == "title"
      return overdue_rentals.joins(:customer).order("customers.name") if params_sort == "name"
      return overdue_rentals.order(params_sort)
    else
      return "Unable to sort with '#{params_sort}'. Please resubmit with a valid sort parameter (title ,name, checkout_date, or due_date)"
    end
  end

end
