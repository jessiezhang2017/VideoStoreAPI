require "test_helper"
require "pry"
describe RentalsController do
  describe "check_out" do
    let(:movie) { movies(:ring)  }
    let(:customer) { customers(:lily)  }
    let(:check_out_data) {
      {
        customer_id: customer.id,
        movie_id: movie.id
      }
    }

    it "renders json" do
      post check_out_movie_path, params: check_out_data

      body = JSON.parse(response.body)
      expect(response.header['Content-Type']).must_include 'json'
      must_respond_with :success
    end

    it "returns a rental with exactly the required fields" do
      expect {
        post check_out_movie_path, params: check_out_data
      }.must_change('Rental.count', 1)

      body = JSON.parse(response.body)

      expect(Rental.last.id).must_equal body["id"]
      expect(Rental.last.check_out_date).must_equal body["check_out_date"].in_time_zone
      expect(Rental.last.due_date).must_equal body["due_date"].in_time_zone

      expect(Rental.last.customer).must_equal customer
      expect(Rental.last.movie).must_equal movie
    end

    it "updates movie available_inventory (-1)" do
      available_inventory = movie.available_inventory
      id = movie.id
      post check_out_movie_path, params: check_out_data

      updated_movie = Movie.find_by(id: id)

      expect(updated_movie.available_inventory).must_equal available_inventory - 1
    end

    it "updates customer movies_checked_out_count (+1)" do
      movies_checked_out_count = customer.movies_checked_out_count
      id = customer.id
      post check_out_movie_path, params: check_out_data

      updated_customer = Customer.find_by(id: id)

      expect(updated_customer.movies_checked_out_count).must_equal movies_checked_out_count + 1
    end

    it "returns an error message with invalid params" do
      bad_check_out_data =       {
        customer_id: "hello",
        movie_id: "goodbye"
      }

      expect {
        post check_out_movie_path, params: bad_check_out_data
      }.wont_change('Rental.count')

      body = JSON.parse(response.body)

      expect(body).must_include "errors"
      expect(body["errors"]).must_include "customer"
      expect(body["errors"]).must_include "movie"
      must_respond_with :bad_request
    end
  end

  describe "check_in" do

    it "finds the rental based off of the movie_id and customer_id params and 'checked out' status" do
      # current_rental = Rental.find_by(movie_id: rental_params[:movie_id], customer_id: rental_params[:customer_id], status: "checked out")
    end

    it "returns an error with invalid params/a rental doesn't exist" do
      # if current_rental.nil?
      #   render json: {ok: false, message: "Your rental was not found"}, status: :not_found
    end

    it "succeeds with valid rental" do
      # current_rental.check_in
      # render json: {ok: true, message: "Movie successfully returned"}, status: :ok
    end
    it "updates the rental's status and customer and movie inventories" do
      # self.customer.check_in
      # self.movie.check_in
      # self.update(status: "returned")
    end
  end

  describe "overdue" do
    it "renders json" do
    end

    it "returns an error message if there are invalid sort params" do
      # render json: {ok: false, message: overdue_rentals }, status: :not_found
    end

    it "returns an error message if there are invalid p or n params" do

    end

    it "returns a message if there are no overdue rentals" do
      # elsif overdue_rentals.length == 0
      #   render json: {ok: true, message: "There are no overdue rentals!"}, status: :ok
    end

    it "returns overdue rentals with valid sort params" do

    end

    it "returns overdue rentals with valid p and n params" do

    end

    it "returns overdue rentals with valid p and n params and valid sort params" do

    end

    it "returns overdue rentals with no params" do
      # render :json => overdue_rentals, :include => {:movie => {:only => :title}, :customer => {:only => [:name, :postal_code]}}, :except => [:created_at, :updated_at], status: :ok
    end
  end
end
