require "test_helper"

describe RentalsController do
  describe "check_out" do
    it "renders json" do

    end

    it "returns a rental with exactly the required fields" do
      # render json: { id: rental.id , checkout_date: rental.check_out_date, due_date:rental.due_date}, status:  :ok
    end

    it "updates movie available_inventory" do

    end

    it "updates customer movies_checked_out_count" do

    end

    it "returns an error message with invalid params" do
      #render json: { ok: false, errors: rental.errors.messages}, status: :bad_request
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

    it "returns overdue rentals with valid p or n params" do

    end

    it "returns overdue rentals with no sort params or  p and n params provided" do
      # render :json => overdue_rentals, :include => {:movie => {:only => :title}, :customer => {:only => [:name, :postal_code]}}, :except => [:created_at, :updated_at], status: :ok
    end
  end
end
