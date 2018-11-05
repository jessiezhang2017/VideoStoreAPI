require "test_helper"

describe Rental do
  describe "relationships" do
    it "belongs to a customer" do
      rental = rentals(:one)
      rental.must_respond_to :customer
      rental.customer.must_be_kind_of Customer
    end

    it "belongs to a movie" do
      rental = rentals(:one)
      rental.must_respond_to :movie
      rental.movie.must_be_kind_of Movie
    end
  end

  describe "validations" do

    it "must have a checkout_date" do
      rental = rentals(:one)

      rental.check_out_date = nil
      result = rental.save
      result.must_equal false

      rental.check_out_date = "2018-12-03 13:04:10"
      result = rental.save
      result.must_equal true
    end

    it "must have a due_date" do
      rental = rentals(:one)

      rental.due_date = nil
      result = rental.save
      result.must_equal false

      rental.due_date = "2018-12-10 13:04:10"
      result = rental.save
      result.must_equal true
    end

    it "must have a status" do
      rental = rentals(:one)
      rental.status = nil

      result = rental.save

      result.must_equal false
    end

    it "must have a valid status" do
      rental = rentals(:one)

      rental.status = "cheese"
      result = rental.save
      result.must_equal false

      rental.status = "checked out"
      result = rental.save
      result.must_equal true
    end
  end
end
