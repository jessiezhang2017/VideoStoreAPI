require "test_helper"
require "pry"
describe Customer do

  describe "relationships" do
    it "has many rentals" do
      customer = customers(:mike)

      customer.must_respond_to :rentals

      customer.rentals.each do |rental|
        rental.customer.must_be_kind_of Customer
        rental.must_be_kind_of Rental
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

  describe "check_out" do
    it "updates the customer's movies_checked_out_count (+1)" do
      customer = customers(:mike)
      movies_checked_out_count = customer.movies_checked_out_count

      customer.check_out
      expect(customer.movies_checked_out_count).must_equal movies_checked_out_count + 1
    end
  end

  describe "check_in" do
    it "updates the customer's movies_checked_out_count (-1)" do
      customer = customers(:mike)
      movies_checked_out_count = customer.movies_checked_out_count

      customer.check_in
      expect(customer.movies_checked_out_count).must_equal movies_checked_out_count - 1
    end
  end

  describe "find_rentals" do

    it "returns rentals with supplied status" do
      customer = customers(:mike)
      checked_out_rentals = customer.find_rentals("checked out")

      checked_out_rentals.each do |rental|
        expect(rental.status).must_equal "checked out"
        expect(rental.customer).must_equal customer
      end
    end

  end

  describe "paginate_check" do
    it "returns rentals if n and p params are absent/nil" do
      customer = customers(:mike)
      current_rentals = Customer.paginate_check(customer.rentals, nil, nil)

      current_rentals.each do |rental|
        expect(rental).must_be_kind_of Rental
      end

      expect(rentals).must_be_kind_of Array
    end

    it "returns a string if n OR p params are absent/nil" do
      customer = customers(:mike)
      current_rentals = Customer.paginate_check(customer.rentals, 1, nil)

      expect(current_rentals).must_be_kind_of String
      expect(current_rentals).must_equal "Both 'p' and 'n' must be present and a number to paginate. Please resubmit with valid parameters."
    end

    it "paginates rentals if n and p params are numeric and positive" do
      n_params = 3
      p_params = 1
      customer = customers(:mike)
      current_rentals = Customer.paginate_check(customer.rentals, p_params, n_params)

      expect(current_rentals.length).must_equal n_params
    end
    #
    it "returns a string if n or p params are not numeric or positive" do
      customer = customers(:mike)
      current_rentals = Customer.paginate_check(customer.rentals, "hello", "nil")
      expect(current_rentals).must_be_kind_of String
      expect(current_rentals).must_equal "Both 'p' and 'n' must be present and a number to paginate. Please resubmit with valid parameters."

      current_rentals = Customer.paginate_check(customer.rentals, "-1", 2)
      expect(current_rentals).must_be_kind_of String
      expect(current_rentals).must_equal "Both 'p' and 'n' must be present and a number to paginate. Please resubmit with valid parameters."
    end
  end

  describe "sort_check" do
    it "returns rentals if the params are nil" do
      customer = customers(:mike)
      customer_rentals = Customer.sort_check(customer.rentals, nil, ["title", "check_out_date", "due_date"])

      customer_rentals.each do |rental|
        expect(rental).must_be_kind_of Rental
      end

    end

    it "returns rentals sorted by movie title if params are 'title'" do
      customer = customers(:mike)
      sorted_rentals = customer.rentals.joins(:movie).order("movies.title")
      rentals = Customer.sort_check(customer.rentals, "title", ["title", "check_out_date", "due_date"])

      rentals.each.with_index do |rental, index|
        expect(rental).must_be_kind_of Rental
        expect(rental.movie.title).must_equal sorted_rentals[index].movie.title
      end
    end

    it "returns rentals sorted by 'check_out_date' or 'due_date'" do
      customer = customers(:mike)
      sorted_rentals = customer.rentals.order("check_out_date")
      rentals = Customer.sort_check(customer.rentals, "check_out_date", ["title", "check_out_date", "due_date"])


      rentals.each.with_index do |rental, index|
        expect(rental).must_be_kind_of Rental
        expect(rental.check_out_date).must_equal sorted_rentals[index].check_out_date
      end

      sorted_rentals = customer.rentals.order("due_date")
      rentals = Customer.sort_check(customer.rentals, "due_date", ["title", "check_out_date", "due_date"])


      rentals.each.with_index do |rental, index|
        expect(rental).must_be_kind_of Rental
        expect(rental.due_date).must_equal sorted_rentals[index].due_date
      end
    end

      it "returns a string if the params are invalid" do
        customer = customers(:mike)

        toast = "toast"
        rentals = Customer.sort_check(customer.rentals, "toast", ["title", "check_out_date", "due_date"])
        expect(rentals).must_be_kind_of String
        expect(rentals).must_equal "Unable to sort with '#{toast}'. Please resubmit with a valid sort parameter (#{["title", "check_out_date", "due_date"]})"
      end
  end

end
