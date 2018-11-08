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

  def find_rentals(status)
    current_rentals = self.rentals.where("status = '#{status}'").map { |rental| { title: rental.movie.title, check_out_date: rental.check_out_date, due_date: rental.due_date } }
    return current_rentals
  end

  def self.paginate_check(customer_rentals, params_p, params_n)
    if params_p.nil? && params_n.nil?
      return customer_rentals
    elsif params_p.nil? || params_n.nil?
      return "Both 'p' and 'n' must be present and a number to paginate. Please resubmit with valid parameters."
    elsif (params_p !~ /\D/) && (params_n !~ /\D/)
      return customer_rentals.paginate(:page => params_p, :per_page => params_n)
    else
      return "Both 'p' and 'n' must be present and a number to paginate. Please resubmit with valid parameters."
    end
  end

  def self.sort_check(customer_rentals, params_sort, valid_fields)
    if params_sort.nil?
      return customer_rentals
    elsif valid_fields.include? (params_sort)
      return customer_rentals.joins(:movie).order("movies.title") if params_sort == "title"
      return customer_rentals.order(params_sort)
    else
      return "Unable to sort with '#{params_sort}'. Please resubmit with a valid sort parameter (#{valid_fields})"
    end
  end

end
