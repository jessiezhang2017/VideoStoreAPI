require "test_helper"

describe Customer do

  describe "relationships" do

    it "has many rentals" do
      customer = customers(:mike)

      customer.must_respond_to :rentals

      customer.rentals.each do |rental|
        rental.customer.must_be_kind_of Customer
      end
    end

  end

  describe "validations" do
    it "must have a name" do
      customer = customers(:mike)

      customer.name = nil
      result = customer.save
      result.must_equal false

      customer.name = "Jane"
      result = customer.save
      result.must_equal true
    end

    it "must have movies checked out count" do
      customer = customers(:mike)

      customer.movies_checked_out_count = nil
      result = customer.save
      result.must_equal false

      customer.movies_checked_out_count = 1
      result = customer.save
      result.must_equal true
    end

    it "must have 0 or more movies checked out" do
      customer = customers(:mike)

      customer.movies_checked_out_count = -1
      result = customer.save
      result.must_equal false

      customer.movies_checked_out_count = 0
      result = customer.save
      result.must_equal true

      customer.movies_checked_out_count = 1
      result = customer.save
      result.must_equal true
    end
  end

end
