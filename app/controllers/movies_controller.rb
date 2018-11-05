class MoviesController < ApplicationController

  def zomg
      render json: { ok: true, message: 'it works!'}, status: :ok
  end
end
