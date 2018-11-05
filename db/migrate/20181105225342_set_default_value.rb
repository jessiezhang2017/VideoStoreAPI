class SetDefaultValue < ActiveRecord::Migration[5.2]
  def change
    change_column :customers, :movies_checked_out_count, :integer, :default => 0
    change_column :movies, :inventory, :integer, :default => 0
    change_column :rentals, :status, :string, :default => "checked out"

  end
end
