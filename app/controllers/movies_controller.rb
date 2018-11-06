class MoviesController < ApplicationController

  def zomg
    render json:{ ok: true, message: 'it works!'}, status: :ok
  end

  def create
    movie = Movie.new(movie_params)

    if movie.save
      render json: { ok: true, movie: movie.as_json( except: [:created_at, :updated_at] )}, status: :ok
    else
      render json: { ok: false, errors: movie.errors.messages}, status: :bad_request
    end
  end

  private

  def movie_params
    params.require(:movie).permit(:title, :overview, :release_date, :inventory)
  end
end
