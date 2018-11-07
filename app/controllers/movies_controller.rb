class MoviesController < ApplicationController

  def index
    if sort?
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
    movie = Movie.find_by(id: params[:id])

    if movie.nil?
       render json: {ok: false, message: 'not found'}, status: :not_found
    else
      render json: movie.as_json(except: [:created_at, :updated_at]), status: :ok
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

  private

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

  def movie_params
    params.permit(:title, :overview, :release_date, :inventory, :sort, :n, :p)
  end


end
