class DeleteCustomerIdMovieIdFromMovie < ActiveRecord::Migration[5.2]
  def change
    remove_column :movies, :movie_id
    remove_column :movies, :customer_id  
  end
end
