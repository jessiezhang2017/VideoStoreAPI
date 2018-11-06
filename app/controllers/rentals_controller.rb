class RentalsController < ApplicationController
  def check_in
    movie = Movie.find_by(id: params[:movie_id])
    customer = Customer.find_by(id: params[:customer_id])
    current_rental = nil

    customer.rentals.each do |rental|
      if rental.movie == movie && rental.customer == customer && rental.status == "checked out"
        current_rental = rental
        break
      end
    end

    if movie.nil?
      nil_response(movie, "movie")
    elsif customer.nil?
      nil_response(customer, "customer")
    elsif current_rental.nil?
      nil_response(current_rental, "rental agreement")
    else
      render json: {ok: true, message: "Movie successfully returned"}, status: :ok
      current_rental.update(status: "returned")
      checked_out_count = customer.movies_checked_out_count - 1
      customer.update(movies_checked_out_count: checked_out_count)
      updated_inventory = movie.inventory + 1
      movie.update(inventory: updated_inventory)
    end

  end

  private

  def check_in_params
    params.permit(:customer_id, :movie_id)
  end

  def nil_response(object, name)
    if object.nil?
      render json: {ok: false, message: "The #{name} for this rental was not found"}, status: :not_found
    end
  end

end
