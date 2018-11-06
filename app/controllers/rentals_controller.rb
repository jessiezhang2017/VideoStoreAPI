class RentalsController < ApplicationController

  def check_out

    rental = Rental.new

    rental.customer = Customer.find_by(id: params[:customer_id])
    rental.movie = Movie.find_by(id: params[:movie_id])
    rental.check_out_date = Date.today

    rental.due_date = rental.check_out_date + 7
    rental.customer.movies_checked_out_count += 1
    rental.movie.inventory -= 1

    if rental.save
      render json: { id: rental.id , checkout_date: rental.check_out_date, due_date:rental.due_date}, status:  :ok
    else
      render json: { ok: false, errors: rental.errors.messages}, status: :bad_request
    end
  end

  

end
