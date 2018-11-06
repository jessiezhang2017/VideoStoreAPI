require "test_helper"
describe MoviesController do

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

  describe "index" do
    it "is a real working route and returns JSON" do
      # Act
      get movies_path

      # Assert
      expect(response.header['Content-Type']).must_include 'json'
      must_respond_with :success
    end

    it "returns an Array" do
      # Act
      get movies_path

      # Convert the JSON response into a Hash
      body = JSON.parse(response.body)

      # Assert
      expect(body).must_be_kind_of Array
    end

    it "returns all of the movies" do
      # Act
      get movies_path

      # Convert the JSON response into a Hash
      body = JSON.parse(response.body)

      # Assert
      expect(body.length).must_equal Movie.count
    end

    it "returns moviess with exactly the required fields" do
      keys = %w(id title release_date)

      # Act
      get movies_path

      # Convert the JSON response into a Hash
      body = JSON.parse(response.body)

      # Assert that each
      body.each do |movie|
        expect(movie.keys).must_equal keys
        expect(movie.keys.length).must_equal keys.length
      end
    end
  end

  it "can get a movie" do
      get movie_path(movies(:taken).id)
      must_respond_with :success
    end

    it "responds with a 404 message if no movie is found" do
      id = -1
      get movie_path(id)
      must_respond_with :not_found
    end

end
