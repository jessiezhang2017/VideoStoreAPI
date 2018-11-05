class CreateRentals < ActiveRecord::Migration[5.2]
  def change
    create_table :rentals do |t|
      t.datetime :check_out_date
      t.datetime :due_date
      t.string :status

      t.timestamps
    end
  end
end
