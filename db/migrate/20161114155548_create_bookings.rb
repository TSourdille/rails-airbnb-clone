class CreateBookings < ActiveRecord::Migration[5.0]
  def change
    create_table :bookings do |t|
      t.references :boat, foreign_key: true
      t.references :user, foreign_key: true
      t.date :start_at
      t.date :end_at
      t.text :user_review
      t.text :owner_review
      t.integer :user_rating
      t.integer :owner_rating
      t.date :validated_at

      t.timestamps
    end
  end
end
