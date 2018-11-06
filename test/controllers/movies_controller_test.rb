require "test_helper"
require 'pry'
describe MoviesController do
  # it "must be a real test" do
  #   flunk "Need real tests"
  # end

  describe "create" do
    let(:movie_data) {
      {
        title: "Jack",
        overview: "American comedy-drama film starring Robin Williams and directed by Francis Ford Coppola.",
        release_date: "1996-08-09",
        inventory: 1
      }
    }

    it "returns json" do
      post create_movie_path, params: { movie: movie_data }
      expect(response.header['Content-Type']).must_include 'json'
    end

    it "creates a movie with valid data and returns it's ID" do
      expect {
        post create_movie_path, params: { movie: movie_data }
      }.must_change "Movie.count", 1

      body = JSON.parse(response.body)
      expect(body).must_be_kind_of Hash
      expect(body["movie"]).must_include "id"

      movie = Movie.find(body["movie"]["id"].to_i)

      expect(movie.title).must_equal movie_data[:title]
      must_respond_with :success

    end

    it "fails to create a movie and returns an error with invalid data" do
      movie_data["title"] = nil

      expect {
        post create_movie_path, params: { movie: movie_data }
      }.wont_change "Movie.count"

      body = JSON.parse(response.body)
      expect(body).must_be_kind_of Hash
      expect(body).must_include "errors"
      expect(body["errors"]).must_include "title"
      must_respond_with :bad_request
    end

  end

end
