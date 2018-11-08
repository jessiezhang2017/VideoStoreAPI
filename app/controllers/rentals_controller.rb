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
    overdue_rentals = Rental.paginate_check(Rental.where("status = 'checked out' AND due_date < ?", Date.today), rental_params["p"], rental_params["n"])
    #if overdue_rentals is a String, that string is an error message
    overdue_rentals = Rental.sort_check(overdue_rentals, rental_params["sort"]) if overdue_rentals.class != String
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

end
