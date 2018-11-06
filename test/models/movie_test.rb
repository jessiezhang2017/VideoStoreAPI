require "test_helper"

describe Movie do
  describe "validations" do
    it "must have a title" do
      movie = movies(:taken)

      movie.title = nil
      result = movie.save
      result.must_equal false

      movie.title = "Jane"
      result = movie.save
      result.must_equal true
    end

    it "must have inventory" do
      movie = movies(:taken)

      movie.inventory = nil
      result = movie.save
      result.must_equal false

      movie.inventory = 1
      result = movie.save
      result.must_equal true
    end

    it "must have 0 or more inventory" do
      movie = movies(:taken)

      movie.inventory =  -1
      result = movie.save
      result.must_equal false

      movie.inventory = 0
      result = movie.save
      result.must_equal true

      movie.inventory = 1
      result = movie.save
      result.must_equal true
    end

    it "must have an available inventory" do
      movie = movies(:taken)

      movie.available_inventory = nil
      result = movie.save
      result.must_equal false

      movie.available_inventory = 1
      result = movie.save
      result.must_equal true
    end

    it "must have 0 or more inventory" do
      movie = movies(:taken)

      movie.available_inventory =  -1
      result = movie.save
      result.must_equal false

      movie.available_inventory = 0
      result = movie.save
      result.must_equal true

      movie.available_inventory = 1
      result = movie.save
      result.must_equal true
    end

  end
end
