class CustomersController < ApplicationController

  VALID_FIELDS = ["name", "registered_at", "postal_code" ]

  def index
    if cust_params["sort"] && cust_params["p"] && cust_params["n"] #paginate and sort
      customers = Customer.paginate(:page => cust_params["p"], :per_page => cust_params["n"]).order(cust_params["sort"]) if VALID_FIELDS.include? cust_params["sort"]
    elsif cust_params["p"] && cust_params["n"] # paginate only
      customers = Customer.paginate(:page => cust_params["p"], :per_page => cust_params["n"])
    elsif cust_params["sort"] # sort only
      customers = Customer.all.order(cust_params["sort"]) if VALID_FIELDS.include? cust_params["sort"]
    else # neither
      customers = Customer.all
    end

    if customers
      render json: customers.as_json( only: [:id, :name, :registered_at, :postal_code, :phone, :movies_checked_out_count] ), status: :ok
    else
      render json: {ok: false, message: 'not found'}, status: :not_found
    end
  end

  private

  def cust_params
    params.permit(:sort, :n, :p)
  end
end
