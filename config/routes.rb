Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get "/movies", to: "movies#index", as: "movies"
  post "/movies", to: "movies#create", as: "create_movie"
  get "/movies/:id", to: "movies#show", as: "movie"

  post "/rentals/check-out", to: "rentals#check_out", as: "check_out_movie"
  post "/rentals/check-in", to: "rentals#check_in", as: "check_in_movie"
  get "/rentals/overdue", to: "rentals#overdue", as: "overdue"

  get "/customers", to: "customers#index", as: "customers"
  get "/customers/:id/current", to: "customers#current", as: "current_customers"
  get "/customers/:id/history", to: "customers#history", as: "past_customers"

  get "/zomg", to: "movies#zomg", as: "zomg"

end
