class CustomersController < ApplicationController

  def index

    if Customer.sort?(cust_params["sort"])
      customers = paginate_check.order(cust_params["sort"])
    else
      customers = paginate_check
    end

    if customers
      render json: customers.as_json( only: [:id, :name, :registered_at, :postal_code, :phone, :movies_checked_out_count] ), status: :ok
    else
      render json: {ok: false, message: 'not found'}, status: :not_found
    end
  end

  # GET /customers/:id/current
  # List the movies a customer currently has checked out (using customer id as params)
  def current
    customer = Customer.find_by(id: cust_params["id"])
    if customer.nil?
      render json: { ok: false, message: "Unable to find customer with ID: #{cust_params["id"]}."}, status: :not_found
    else
      movies_checked_out = []
      customer.rentals.each do |rental|
        movies_checked_out << rental if rental.status == "checked out"
      end
      if movies_checked_out == []
        render json: { ok: false, message: "#{customer.name} has 0 movies checked out."}, status: :ok
      else
      render :json => movies_checked_out, :include => {:movie => {:only => :title}}, :only => [:checkout_date, :due_date], status: :ok
      end
    end
  end

  private

  def paginate_check
    if cust_params["p"] && cust_params["n"]
      return Customer.paginate(:page => cust_params["p"], :per_page => cust_params["n"])
    else
      return Customer.all
    end
  end

  def cust_params
    params.permit(:sort, :n, :p, :id)
  end
end
