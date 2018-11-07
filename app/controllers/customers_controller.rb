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

  private

  def paginate_check
    if cust_params["p"] && cust_params["n"]
      return Customer.paginate(:page => cust_params["p"], :per_page => cust_params["n"])
    else
      return Customer.all
    end
  end

  def cust_params
    params.permit(:sort, :n, :p)
  end
end
