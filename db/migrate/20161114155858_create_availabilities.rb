class CreateAvailabilities < ActiveRecord::Migration[5.0]
  def change
    create_table :availabilities do |t|
      t.date :start_at
      t.date :end_at
      t.references :boat, foreign_key: true

      t.timestamps
    end
  end
end
