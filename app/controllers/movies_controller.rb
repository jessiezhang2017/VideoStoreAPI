require "pry"
class MoviesController < ApplicationController
  before_action :find_movie, only: [:show, :current, :history]

  def index
    if Movie.sort?(movie_params["sort"])
      movies = paginate_check.order(movie_params["sort"])
    else
      movies = paginate_check
    end

    if movies
       render json: movies.as_json( only: [:id, :title, :release_date]), status: :ok
    else
       render json: {ok: false, message: 'not found'}, status: :not_found
    end
  end

  def show
    # movie = Movie.find_by(id: params[:id])
    #
    if movie.nil?
       render json: {ok: false, message: 'not found'}, status: :not_found
    else
      render json: @movie.as_json(except: [:created_at, :updated_at]), status: :ok
    end
  end

  def zomg
    render json:{ ok: true, message: 'it works!'}, status: :ok
  end

  def create
    movie = Movie.new(movie_params)
    movie.available_inventory = movie.inventory

    if movie.save
      render json: { id: movie.id }, status:  :ok
    else
      render json: { ok: false, errors: movie.errors.messages}, status: :bad_request
    end
  end


  def current

    if @movie
      @current_rentals = @movie.rentals.where("status = 'checked out'").map { |rental| { customer_id: rental.customer.id, customer_name: rental.customer.name, postal_code: rental.customer.postal_code, check_out_date: rental.check_out_date, due_date: rental.due_date } }

      if @current_rentals == nil || @current_rentals = []

         render json: {ok: false, message: 'no current rental for this movie'}, status: :not_found
      else
         render json: { current_rentals: @current_rentals }
      end

    else
       render json: {ok: false, message: 'movie not found'}, status: :not_found

    end
  end

  def history



  end

  private

  def find_movie
    @movie = Movie.find(params[:id].to_i)
    # if @movie.nil?
    #   render json: {ok: false, message: 'not found'}, status: :not_found
    # end
  end

  def paginate_check
    if movie_params["p"] && movie_params["n"]

      return Movie.paginate(:page => movie_params["p"], :per_page => movie_params["n"])
    else
      return Movie.all
    end
  end

  def movie_params
    params.permit(:title, :overview, :release_date, :inventory, :sort, :n, :p)
  end

end
