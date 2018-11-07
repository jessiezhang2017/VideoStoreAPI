require "pry"
class RentalsController < ApplicationController

  def check_out
    customer = Customer.find_by(id: params[:customer_id])
    movie = Movie.find_by(id: params[:movie_id])

    rental = Rental.new
    rental.customer = customer
    rental.movie = movie
    rental.check_out_date = Date.today
    rental.due_date = rental.check_out_date + 7

    if rental.save
      updated_movie = rental.customer.movies_checked_out_count += 1
      updated_inventory = rental.movie.available_inventory - 1
      rental.movie.update(available_inventory: updated_inventory)
      rental.customer.update(movies_checked_out_count: updated_movie)

      render json: { id: rental.id , checkout_date: rental.check_out_date, due_date:rental.due_date}, status:  :ok
    else
      nil_response(customer, "customer")
      nil_response(movie, "movie")
      render json: { ok: false, errors: rental.errors.messages}, status: :bad_request
    end
  end

  def check_in(movie_id, customer_id)
    movie = Movie.find_by(id: params[:movie_id])
    customer = Customer.find_by(id: params[:customer_id])
    current_rental = nil

    customer.rentals.each do |rental|
      if rental.movie == movie && rental.customer == customer && rental.status == "checked out"
        current_rental = rental
        break
      end
    end

    if movie.nil? || customer.nil? || current_rental.nil?
      nil_response(movie, "movie")
      nil_response(customer, "customer")
      nil_response(current_rental, "rental agreement")
    else
      render json: {ok: true, message: "Movie successfully returned"}, status: :ok
      current_rental.update(status: "returned")
      checked_out_count = customer.movies_checked_out_count - 1
      customer.update(movies_checked_out_count: checked_out_count)
      updated_available_inventory = movie.available_inventory + 1
      movie.update(available_inventory: updated_available_inventory)
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

  def nil_response(object, name)
    if object.nil?
      render json: {ok: false, message: "The #{name} for this rental was not found"}, status: :not_found
      return
    end
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
