require "test_helper"
require "pry"
describe Rental do
  describe "relationships" do
    it "belongs to a customer" do
      rental = rentals(:one)

      expect(rental).must_respond_to :customer
      expect(rental.customer).must_be_kind_of Customer
    end

    it "belongs to a movie" do
      rental = rentals(:one)

      expect(rental).must_respond_to :movie
      expect(rental.movie).must_be_kind_of Movie
    end
  end

  describe "validations" do

    it "must have a checkout_date" do
      rental = rentals(:one)

      rental.check_out_date = nil
      result = rental.save
      expect(result).must_equal false

      rental.check_out_date = "2018-12-03 13:04:10"
      result = rental.save
      expect(result).must_equal true

    end

    it "must have a due_date" do
      rental = rentals(:one)

      rental.due_date = nil
      result = rental.save
      expect(result).must_equal false

      rental.due_date = "2018-12-10 13:04:10"
      result = rental.save
      expect(result).must_equal true
    end

    it "must have a status" do
      rental = rentals(:one)
      rental.status = nil

      result = rental.save

      expect(result).must_equal false
    end

    it "must have a valid status" do
      rental = rentals(:one)

      rental.status = "cheese"
      result = rental.save
      expect(result).must_equal false

      rental.status = "checked out"
      result = rental.save
      expect(result).must_equal true
    end
  end

  describe "check_out" do
    let(:movie) { movies(:taken)  }
    let(:customer) { customers(:mike)  }
    let(:today) { Date.today }

    it "makes a new rental with a customer and a movie" do
      rental = Rental.check_out(customer.id, movie.id)

      expect(rental).must_be_kind_of Rental
      expect(rental.movie).must_be_kind_of Movie
      expect(rental.customer).must_be_kind_of Customer
    end

    it "doesn't assign a customer or movie with invalid params " do
      rental = Rental.check_out("hello", "test")

      expect(rental).must_be_kind_of Rental
      expect(rental.movie).must_be_nil
      expect(rental.customer).must_be_nil
    end

    it "gives it a check_out_date of today" do
      rental = Rental.check_out(customer.id, movie.id)

      expect(rental.check_out_date).must_equal today
    end

    it "gives it a due_date of a week from today" do
      rental = Rental.check_out(customer.id, movie.id)

      expect(rental.due_date).must_equal today + 7
    end

  end

  describe "check_in" do
    let(:rental) { rentals(:one)  }

    it "updates the rental's status to returned" do
      expect(rental.status).must_equal "checked out"
      rental.check_in
      expect(rental.status).must_equal "returned"
    end

    it "decrements the rental's customer's movies_checked_out_count by 1" do
      count = rental.customer.movies_checked_out_count
      rental.check_in
      expect(rental.customer.movies_checked_out_count).must_equal count - 1
    end

    it "increments the rental's movie's available_inventory by 1" do
      inventory = rental.movie.available_inventory
      rental.check_in
      expect(rental.movie.available_inventory).must_equal inventory + 1
    end

  end

  describe "paginate_check" do
    it "returns rentals if n and p params are absent/nil" do
      rentals = Rental.paginate_check(Rental.all, nil, nil)

      rentals.each do |rental|
        expect(rental).must_be_kind_of Rental
      end

      expect(rentals).must_be_kind_of ActiveRecord::Relation
    end

    it "returns a string if n or p params are absent/nil" do
      rentals = Rental.paginate_check(Rental.all, 1, nil)

      expect(rentals).must_be_kind_of String
      expect(rentals).must_equal "Both 'p' and 'n' must be present and a number to paginate. Please resubmit with valid parameters."
    end

    it "paginates rentals if n and p params are numeric and positive" do
      n_params = 3
      p_params = 1
      rentals = Rental.paginate_check(Rental.all, p_params, n_params)

      expect(rentals).must_be_kind_of ActiveRecord::Relation
      expect(rentals.length).must_equal n_params
    end

    it "returns a string if n or p params are not numeric or positive" do
      rentals = Rental.paginate_check(Rental.all, "hello", "nil")
      expect(rentals).must_be_kind_of String
      expect(rentals).must_equal "Both 'p' and 'n' must be present and a number to paginate. Please resubmit with valid parameters."

      rentals = Rental.paginate_check(Rental.all, "-1", 2)
      expect(rentals).must_be_kind_of String
      expect(rentals).must_equal "Both 'p' and 'n' must be present and a number to paginate. Please resubmit with valid parameters."
    end
  end

  describe "sort_check" do
    it "returns rentals if the params are nil" do
      rentals = Rental.sort_check(Rental.all, nil)

      expect(rentals).must_be_kind_of ActiveRecord::Relation
      rentals.each do |rental|
        expect(rental).must_be_kind_of Rental
      end
    end

    it "returns rentals sorted by movie title if params are 'title'" do
      sorted_rentals = Rental.all.joins(:movie).order("movies.title")
      rentals = Rental.sort_check(Rental.all, "title")

      rentals.each.with_index do |rental, index|
        expect(rental).must_be_kind_of Rental
        expect(rental.movie.title).must_equal sorted_rentals[index].movie.title
      end
    end

    it "returns rentals sorted by customer if params are 'name'" do
      sorted_rentals = Rental.all.joins(:customer).order("customers.name")
      rentals = Rental.sort_check(Rental.all, "name")

      rentals.each.with_index do |rental, index|
        expect(rental).must_be_kind_of Rental
        expect(rental.customer.name).must_equal sorted_rentals[index].customer.name
      end
    end

    it "returns rentals sorted by 'check_out_date' or 'due_date'" do
      sorted_rentals = Rental.all.order("check_out_date")
      rentals = Rental.sort_check(Rental.all, "check_out_date")

      rentals.each.with_index do |rental, index|
        expect(rental).must_be_kind_of Rental
        expect(rental.check_out_date).must_equal sorted_rentals[index].check_out_date
      end

      sorted_rentals = Rental.all.order("due_date")
      rentals = Rental.sort_check(Rental.all, "due_date")

      rentals.each.with_index do |rental, index|
        expect(rental).must_be_kind_of Rental
        expect(rental.due_date).must_equal sorted_rentals[index].due_date
      end
    end

    it "returns a string if the params are invalid" do
      toast = "toast"
      rentals = Rental.sort_check(Rental.all, "toast")
      expect(rentals).must_be_kind_of String
      expect(rentals).must_equal "Unable to sort with '#{toast}'. Please resubmit with a valid sort parameter (title ,name, checkout_date, or due_date)"
    end
  end
end
