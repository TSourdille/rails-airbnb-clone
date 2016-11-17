class AddFieldsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :country, :string
    add_column :users, :registered_at, :date
    add_column :users, :phone, :string
    add_column :users, :picture_url, :string
    add_column :users, :avatar_url, :string
  end
end
