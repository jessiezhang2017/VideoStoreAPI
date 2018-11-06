class CustomersController < ApplicationController
  def index
    customers = Customer.all.order(:name)

    render json: customers.as_json( only: [:id, :name, :registered_at, :postal_code, :phone, :movies_checked_out_count] ), status: :ok
  end
end
