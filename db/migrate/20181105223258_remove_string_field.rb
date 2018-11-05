class RemoveStringField < ActiveRecord::Migration[5.2]
  def change
    remove_column :customers, :string
  end
end
