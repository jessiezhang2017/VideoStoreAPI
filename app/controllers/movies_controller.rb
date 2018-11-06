class MoviesController < ApplicationController

  def zomg
    render json:{ ok: true, message: 'it works!'}, status: :ok
  end

  def index

   # will not have a view to use instance vaiable @pets, so new just use pets
   movies = Movie.all

   render json: movies.as_json( only: [:id, :title, :release_date]), status: :ok
 end


end
