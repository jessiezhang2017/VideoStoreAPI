require "pry"

class RentalsController < ApplicationController

  def check_out
    rental = Rental.check_out(rental_params[:customer_id], rental_params[:movie_id])

    if rental.save
      rental.movie.check_out
      rental.customer.check_out

      render json: { id: rental.id , checkout_date: rental.check_out_date, due_date:rental.due_date}, status:  :ok
    else
      render json: { ok: false, errors: rental.errors.messages}, status: :bad_request
    end
  end

  def check_in
    current_rental = Rental.find_by(movie_id: rental_params[:movie_id], customer_id: rental_params[:customer_id], status: "checked out")

    if current_rental.nil?
      render json: {ok: false, message: "Your rental was not found"}, status: :not_found
    else
      current_rental.check_in
      render json: {ok: true, message: "Movie successfully returned"}, status: :ok
    end
  end

  def overdue
    overdue_rentals = paginate_check(Rental.where("status = 'checked out' AND due_date < ?", Date.today))
    overdue_rentals = sort_check(overdue_rentals) if overdue_rentals.class != String
    #if overdue_rentals is a String, that string is an error message
    if overdue_rentals.class == String
      render json: {ok: false, message: overdue_rentals }, status: :not_found
    elsif overdue_rentals.length == 0
      render json: {ok: true, message: "There are no overdue rentals!"}, status: :ok
    else
      render :json => overdue_rentals, :include => {:movie => {:only => :title}, :customer => {:only => [:name, :postal_code]}}, :except => [:created_at, :updated_at], status: :ok
    end
  end

  private

  def rental_params
    params.permit(:customer_id, :movie_id, :sort, :n, :p)
  end

  def paginate_check(overdue_rentals)
    if rental_params["p"].nil? && rental_params["n"].nil?
      return overdue_rentals
    elsif rental_params["p"].nil? || rental_params["n"].nil?
      return "Both 'p' and 'n' must be present and a number to paginate. Please resubmit with valid parameters."
    elsif (rental_params["p"] !~ /\D/) && (rental_params["n"] !~ /\D/)
      return overdue_rentals.paginate(:page => rental_params["p"], :per_page => rental_params["n"])
    else
      return "Both 'p' and 'n' must be present and a number to paginate. Please resubmit with valid parameters."
    end
  end

  def sort_check(overdue_rentals)
    valid_fields = ["title", "name", "checkout_date", "due_date"]
    if rental_params["sort"].nil?
      return overdue_rentals
    elsif valid_fields.include? (rental_params["sort"])
      return overdue_rentals.joins(:movie).order("movies.title") if rental_params["sort"] == "title"
      return overdue_rentals.joins(:customer).order("customers.name") if rental_params["sort"] == "name"
      return overdue_rentals.order(rental_params["sort"])
    else
      return "Unable to sort with '#{rental_params["sort"]}'. Please resubmit with a valid sort parameter (title ,name, checkout_date, or due_date)"
    end
  end

end
