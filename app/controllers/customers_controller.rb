class CustomersController < ApplicationController
  before_action :find_customer, only: [:history, :current]

  def index
    customers = Customer.all
    customers = Customer.paginate_check(customers, cust_params["p"], cust_params["n"])
    customers = Customer.sort_check(customers, cust_params["sort"], ["name", "registered_at", "postal_code"]) if  customers.class != String

    if customers.class == String #return the error
      render json: {ok: false, message: customers }, status: :not_found
    else
      render json: customers.as_json( only: [:id, :name, :registered_at, :postal_code, :phone, :movies_checked_out_count] ), status: :ok
    end
  end

  # GET /customers/:id/current
  # List the movies a customer currently has checked out (using customer id as params)
  def current
    if @customer
      current_rentals = @customer.find_rentals('checked out')
      current_rentals = Customer.paginate_check(current_rentals, cust_params["p"], cust_params["n"])
      current_rentals = Customer.sort_check(current_rentals, cust_params["sort"], ["title", "check_out_date", "due_date"]) if current_rentals.class != String

      if current_rentals.class == String #return the error
        render json: {ok: false, message: current_rentals }, status: :not_found
      elsif current_rentals == []
        render json: { ok: true, message: "#{@customer.name} has 0 movies checked out."}, status: :ok
      else
        current_rentals.map { |rental| { title: rental.movie.title, check_out_date: rental.check_out_date, due_date: rental.due_date } }
        render json: { current_rentals: current_rentals }, status: :ok
      end
    end
  end

  # GET /customers/:id/history
  # List the movies a customer has checked out in the past
  def history
    if @customer
      past_rentals = @customer.find_rentals('returned')
      past_rentals = Customer.paginate_check(past_rentals, cust_params["p"], cust_params["n"])
      past_rentals = Customer.sort_check(past_rentals, cust_params["sort"], ["title", "check_out_date", "due_date"]) if past_rentals.class != String

      if past_rentals.class == String #return the error
        render json: {ok: false, message: past_rentals }, status: :not_found
      elsif past_rentals == []
        render json: { ok: true, message: "#{@customer.name} has 0 past rentals."}, status: :ok
      else
        render json: { past_rentals: past_rentals }, status: :ok
      end
    end
  end

  private
  def find_customer
    @customer = Customer.find_by(id: cust_params["id"])

    if @customer.nil?
      render json: { ok: false, message: "Unable to find customer with ID: #{cust_params["id"]}."}, status: :not_found
    end
  end

  def cust_params
    params.permit(:sort, :n, :p, :id)
  end
end
