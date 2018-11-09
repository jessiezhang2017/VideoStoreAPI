require "test_helper"
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
    let(:movie) { movies(:ring)  }
    let(:customer) { customers(:lily)  }
    let(:data) {
      {
        customer_id: customer.id,
        movie_id: movie.id
      }
    }

    it "returns an error with invalid params/a rental doesn't exist" do
      bad_data =       {
        customer_id: "hello",
        movie_id: "goodbye"
      }
      post check_in_movie_path, params: bad_data

      body = JSON.parse(response.body)

      expect(body["message"]).must_equal "Your rental was not found"
      must_respond_with :not_found
    end

    it "succeeds with valid rental" do
      post check_out_movie_path, params: data
      post check_in_movie_path, params: data

      body = JSON.parse(response.body)
      expect(response.header['Content-Type']).must_include 'json'
      expect(body["message"]).must_equal "Movie successfully returned"
      must_respond_with :success
    end

    it "updates the rental's status and customer and movie inventories" do
      post check_out_movie_path, params: data
      checked_out_rental = Rental.last
      id = checked_out_rental.id
      movies_checked_out_count = checked_out_rental.customer.movies_checked_out_count
      available_inventory = checked_out_rental.movie.available_inventory

      post check_in_movie_path, params: data

      checked_in_rental = Rental.find_by(id: id)

      expect(checked_in_rental.status).must_equal "returned"
      expect(checked_in_rental.customer.movies_checked_out_count).must_equal movies_checked_out_count - 1
      expect(checked_in_rental.movie.available_inventory).must_equal available_inventory + 1
    end
  end

  describe "overdue" do
    it "renders json" do
      get overdue_path

      body = JSON.parse(response.body)
      expect(response.header['Content-Type']).must_include 'json'
      must_respond_with :success
    end

    it "returns an error message if there are invalid sort params" do
      bad_data =       {
        sort: "hello"
      }
      get overdue_path, params: bad_data
      must_respond_with :not_found

      bad_data =       {
        sort: "hello",
        p: 1,
        n: 1
      }
      get overdue_path, params: bad_data
      must_respond_with :not_found
    end

    it "returns an error message if there are invalid p or n params" do
      bad_data =       {
        n: "hello",
        p: "toast"
      }
      get overdue_path, params: bad_data
      must_respond_with :not_found
    end

    it "returns a message if there are no overdue rentals" do
      Rental.all.each do |rental|
        rental.destroy if rental.due_date < Date.today
      end

      get overdue_path
      must_respond_with :ok

      body = JSON.parse(response.body)
      expect(body["message"]).must_equal "There are no overdue rentals!"
    end

    it "returns overdue rentals with valid sort params" do
      fields = %w(id check_out_date due_date status customer_id movie_id movie customer)
      data =       {
        sort: "name"
      }
      get overdue_path, params: data
      get overdue_path
      body = JSON.parse(response.body)

      body.each do |rental|
        expect(rental["status"]).must_equal "checked out"
        rental.keys.must_equal fields
        expect(rental["movie"]).must_include "title"
        expect(rental["customer"]).must_include "name"
        expect(rental["customer"]).must_include "postal_code"
        expect(Date.parse(rental["due_date"])).must_be :<, Date.today
      end

    end

    it "returns overdue rentals with valid p and n params" do
      fields = %w(id check_out_date due_date status customer_id movie_id movie customer)
      data =       {
        n: "1",
        p: "1"
      }

      get overdue_path, params: data

      body = JSON.parse(response.body)
      body.each do |rental|
        expect(rental["status"]).must_equal "checked out"
        rental.keys.must_equal fields
        expect(rental["movie"]).must_include "title"
        expect(rental["customer"]).must_include "name"
        expect(rental["customer"]).must_include "postal_code"
        expect(Date.parse(rental["due_date"])).must_be :<, Date.today
      end

      expect(body.length).must_equal data[:n].to_i
    end

    it "returns overdue rentals with valid p and n params and valid sort params" do
      fields = %w(id check_out_date due_date status customer_id movie_id movie customer)
      data =       {
        n: "1",
        p: "1",
        sort: "name"
      }

      get overdue_path, params: data

      body = JSON.parse(response.body)
      body.each do |rental|
        expect(rental["status"]).must_equal "checked out"
        rental.keys.must_equal fields
        expect(rental["movie"]).must_include "title"
        expect(rental["customer"]).must_include "name"
        expect(rental["customer"]).must_include "postal_code"
        expect(Date.parse(rental["due_date"])).must_be :<, Date.today
      end

      expect(body.length).must_equal data[:n].to_i

    end

    it "returns overdue rentals with no params" do
      fields = %w(id check_out_date due_date status customer_id movie_id movie customer)

      get overdue_path

      body = JSON.parse(response.body)
      body.each do |rental|
        expect(rental["status"]).must_equal "checked out"
        rental.keys.must_equal fields
        expect(rental["movie"]).must_include "title"
        expect(rental["customer"]).must_include "name"
        expect(rental["customer"]).must_include "postal_code"
        expect(Date.parse(rental["due_date"])).must_be :<, Date.today
      end
    end
  end

end
