class CreateBoats < ActiveRecord::Migration[5.0]
  def change
    create_table :boats do |t|
      t.string :type
      t.string :name
      t.string :city
      t.string :capacity
      t.text :description
      t.text :specs
      t.text :equipment
      t.integer :day_rate
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
