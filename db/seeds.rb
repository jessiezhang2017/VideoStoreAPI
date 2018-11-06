JSON.parse(File.read('db/seeds/customers.json')).each do |customer|
  Customer.create!(customer)
end

JSON.parse(File.read('db/seeds/movies.json')).each do |movie|
  movie = Movie.new(movie)
  movie.available_inventory = movie.inventory
  movie.save
end
