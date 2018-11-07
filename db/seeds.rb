JSON.parse(File.read('db/seeds/customers.json')).each do |customer|
  Customer.create!(customer)
end

JSON.parse(File.read('db/seeds/movies.json')).each do |movie|
  new_movie = Movie.new(movie)
  new_movie.available_inventory = new_movie.inventory
  new_movie.save
end

JSON.parse(File.read('db/seeds/rentals.json')).each do |rental|
  new_rental = Rental.new(rental)
  customer = Customer.all.sample
  movie = Movie.all.sample
  new_rental.customer = customer
  new_rental.movie = movie

  if new_rental.status != "returned"
    update_checked_out_count = customer.movies_checked_out_count + 1
    customer.update(movies_checked_out_count: update_checked_out_count)
    update_available_inventory = movie.available_inventory - 1
    movie.update(available_inventory: update_available_inventory)
  end
  new_rental.save
end
