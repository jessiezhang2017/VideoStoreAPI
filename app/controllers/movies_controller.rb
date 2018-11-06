class MoviesController < ApplicationController

  def index
    # will not have a view to use instance vaiable @pets, so new just use pets
    movies = Movie.all

    render json: movies.as_json( only: [:id, :title, :release_date]), status: :ok
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

  def movie_params
    params.permit(:title, :overview, :release_date, :inventory)
  end

end
