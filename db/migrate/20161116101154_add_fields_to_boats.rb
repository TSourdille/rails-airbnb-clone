class AddFieldsToBoats < ActiveRecord::Migration[5.0]
  def change
    add_column :boats, :length, :string
    add_column :boats, :beds, :string
    add_column :boats, :image1, :string
    add_column :boats, :image2, :string
    add_column :boats, :image3, :string
  end
end
