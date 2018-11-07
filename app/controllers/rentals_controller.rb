class RentalsController < ApplicationController

  def check_out

    rental = Rental.check_out(params[:customer_id], params[:movie_id])

    if rental.save
      updated_movie = rental.customer.movies_checked_out_count += 1
      updated_inventory = rental.movie.available_inventory - 1
      rental.movie.update(available_inventory: updated_inventory)
      rental.customer.update(movies_checked_out_count: updated_movie)

      render json: { id: rental.id , checkout_date: rental.check_out_date, due_date:rental.due_date}, status:  :ok
    else
      render json: { ok: false, errors: rental.errors.messages}, status: :bad_request
    end
  end

  def check_in
    current_rental = Rental.find_by(movie_id: params[:movie_id], customer_id: params[:customer_id], status: "checked out")

    if current_rental.nil?
      render json: {ok: false, message: "Your rental was not found"}, status: :not_found
    else
      current_rental.check_in
      render json: {ok: true, message: "Movie successfully returned"}, status: :ok
    end

  end

  def overdue
    #In Progress
    today = Date.today

    overdue_rentals = Rental.where("status = 'checked out'")
    overdue_rentals = overdue_rentals.where("due_date < ?", today)

    # overdue_rentals = Rental.where("due_date < ?", today).order("due_date") #due_date
    # overdue_rentals = Rental.where("due_date < ?", today).order("checkout_date") #checkout_date
    # overdue_rentals = Rental.joins(:movie).where("due_date < ?", today).order("movies.title") #title
    # overdue_rentals = Rental.joins(:customer).where("due_date < ?", today).order("customers.name") #name
    #
    render :json => overdue_rentals, :include => {:movie => {:only => :title}, :customer => {:only => [:name, :postal_code]}}, :except => [:created_at, :updated_at] #works

  end

  private

  def check_in_params
    params.permit(:customer_id, :movie_id)
  end

  def paginate_check
    if movie_params["p"] && movie_params["n"]
      return Movie.paginate(:page => movie_params["p"], :per_page => movie_params["n"])
    else
      return Movie.all
    end
  end

  def sort?
    valid_fields = ["title" ,"release_date"]
    if valid_fields.include? (movie_params["sort"])
      return true
    else
      return false
    end
  end


end
