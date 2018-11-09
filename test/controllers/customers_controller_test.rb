require "test_helper"

describe CustomersController do
  describe "index" do
    it "is a real working route and returns JSON" do
      # Act
      get customers_path

      # Assert
      expect(response.header['Content-Type']).must_include 'json'
      must_respond_with :success
    end

    it "returns an Array" do
      # Act
      get customers_path

      # Convert the JSON response into a Hash
      body = JSON.parse(response.body)

      # Assert
      expect(body).must_be_kind_of Array
    end

    it "returns all of the customers" do
      # Act
      get customers_path

      # Convert the JSON response into a Hash
      body = JSON.parse(response.body)

      # Assert
      expect(body.length).must_equal Customer.count
    end

    it "returns customers with exactly the required fields" do
      keys = %w(id name registered_at postal_code phone movies_checked_out_count)

      # Act
      get customers_path

      # Convert the JSON response into a Hash
      body = JSON.parse(response.body)

      # Assert that each
      body.each do |customer|
        expect(customer.keys).must_equal keys
        expect(customer.keys.length).must_equal keys.length
      end
    end
  end

  describe "current" do
    it "returns current rentals with valid params" do
      data =       {
        sort: "title"
      }
      customer = customers(:mike)
      get current_movies_path(customer.id), params: data

      body = JSON.parse(response.body)
      expect(response.header['Content-Type']).must_include 'json'
      expect(body).must_be_kind_of Hash
    end

    it "returns current rentals with no params" do
      customer = customers(:mike)
      get current_movies_path(customer.id)

      body = JSON.parse(response.body)
      expect(response.header['Content-Type']).must_include 'json'
      expect(body).must_be_kind_of Hash
    end

    it "returns an error mesage with invalid params" do
      data =       {
        sort: "toast"
      }
      customer = customers(:mike)
      get current_movies_path(customer.id), params: data

      body = JSON.parse(response.body)
      expect(response.header['Content-Type']).must_include 'json'
      expect(body).must_be_kind_of Hash
      expect(body["message"]).must_equal "Unable to sort with 'toast'. Please resubmit with a valid sort parameter (#{["title", "check_out_date", "due_date"]})"
    end
  end

  describe "history" do
    it "returns past rentals with valid params" do
      data =       {
        sort: "title"
      }
      customer = customers(:mike)
      get past_movies_path(customer.id), params: data

      body = JSON.parse(response.body)
      expect(response.header['Content-Type']).must_include 'json'
      expect(body).must_be_kind_of Hash
    end

    it "returns past rentals with no params" do
      customer = customers(:mike)
      get past_movies_path(customer.id)

      body = JSON.parse(response.body)
      expect(response.header['Content-Type']).must_include 'json'
      expect(body).must_be_kind_of Hash
    end

    it "returns an error mesage with invalid params" do
      data =       {
        sort: "toast"
      }
      customer = customers(:mike)
      get past_movies_path(customer.id), params: data

      body = JSON.parse(response.body)
      expect(response.header['Content-Type']).must_include 'json'
      expect(body).must_be_kind_of Hash
      expect(body["message"]).must_equal "Unable to sort with 'toast'. Please resubmit with a valid sort parameter (#{["title", "check_out_date", "due_date"]})"
    end
  end

end
