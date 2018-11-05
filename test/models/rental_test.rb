require "test_helper"

describe Rental do
  describe "relations" do
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

end
