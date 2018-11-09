require "test_helper"
require 'pry'
describe MoviesController do

  describe "create" do
    let(:movie_data) {
      {
        title: "Jack",
        overview: "American comedy-drama film starring Robin Williams and directed by Francis Ford Coppola.",
        release_date: "1996-08-09",
        inventory: 1,
        available_inventory: 1
      }
    }

    it "returns json" do
      post create_movie_path, params: { movie: movie_data }
      expect(response.header['Content-Type']).must_include 'json'
    end

    it "creates a movie with valid data and returns it's ID" do
      expect {
        post create_movie_path, params: movie_data
      }.must_change "Movie.count", 1

      body = JSON.parse(response.body)
      expect(body).must_be_kind_of Hash

      expect(body).must_include "id"

      movie = Movie.find(body["id"])

      expect(movie.title).must_equal movie_data[:title]
      expect(movie.overview).must_equal movie_data[:overview]
      expect(movie.inventory).must_equal movie_data[:inventory]
      expect(movie.available_inventory).must_equal movie_data[:available_inventory]

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
      fields = %w(id release_date title)

      # Act
      get movies_path

      # Convert the JSON response into a Hash
      body = JSON.parse(response.body)

      # Assert that each
      body.each do |movie|
        expect(movie.keys.sort).must_equal fields
        expect(movie.keys.length).must_equal fields.length
      end
    end
  end

describe "show" do
  it "is a real working route and returns JSON" do
    # Act
    get movie_path(movies(:taken).id)

    # Assert
    expect(response.header['Content-Type']).must_include 'json'
    must_respond_with :success
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

  it "reurns movie with the require fields" do
    get movie_path(movies(:taken).id)
    body = JSON.parse(response.body)

    fields = %w(available_inventory id inventory overview release_date title)
    expect(body.keys.sort).must_equal fields
  end
 end

 describe "current" do
   it "is a real working route and returns JSON" do
     # Act
     get current_customers_path(movies(:taken).id)

     # Assert
     expect(response.header['Content-Type']).must_include 'json'
     must_respond_with :success
   end

   it "returns an Array " do
     # Act
     get current_customers_path(movies(:taken).id)

     # Convert the JSON response into a Hash
     body = JSON.parse(response.body)

     # Assert
     expect(body).must_be_kind_of Array
   end

   it "returns all of the current customers of that movie" do
     # Act
     get current_customers_path(movies(:taken).id)

     # Convert the JSON response into a Hash
     body = JSON.parse(response.body)

     # Assert
     expect(body.length).must_equal 1
   end

   it "returns customers with exactly the required fields" do
     fields = %w(check_out_date customer_id customer_name due_date postal_code)

     # Act
     get current_customers_path(movies(:taken).id)

     # Convert the JSON response into a Hash
     body = JSON.parse(response.body)

     # Assert that each
     body.each do |customer|
       expect(customer.keys.sort).must_equal fields
       expect(customer.keys.length).must_equal fields.length
     end
   end
 end

 describe "history" do
   it "is a real working route and returns JSON" do
     # Act
     get history_customers_path(movies(:taken).id)

     # Assert
     expect(response.header['Content-Type']).must_include 'json'
     must_respond_with :success
   end

   it "returns an Array" do
     # Act
     get history_customers_path(movies(:taken).id)

     # Convert the JSON response into a Hash
     body = JSON.parse(response.body)

     # Assert
     expect(body).must_be_kind_of Array
   end

   it "returns all of the current customers of that movie" do
     # Act
     get history_customers_path(movies(:taken).id)

     # Convert the JSON response into a Hash
     body = JSON.parse(response.body)

     # Assert
     expect(body.length).must_equal 2
   end

   it "returns customers with exactly the required fields" do
     fields = %w(check_out_date customer_id customer_name due_date postal_code)

     # Act
     get history_customers_path(movies(:taken).id)

     # Convert the JSON response into a Hash
     body = JSON.parse(response.body)

     # Assert that each
     body.each do |customer|
       expect(customer.keys.sort).must_equal fields
       expect(customer.keys.length).must_equal fields.length
     end
   end
 end

end
