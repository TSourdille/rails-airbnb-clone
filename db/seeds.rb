# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def destroy(model)
  model.destroy_all
end

# Doesn't work
def seed_users
  5.times do
    User.new(
    email: Faker::Internet.email,
    password: 'theorules',
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    phone_number: Faker::PhoneNumber.cell_phone,
    boat_license: [true, false].sample
    )
  end
end

def seed_boats
  Availability.destroy_all
  Booking.destroy_all
  Boat.destroy_all
  puts "Seeding 20 boats from anywhere in France"

  boats = JSON.parse(File.read("db/samboat_2016-11-15-15-39.json"))
  users = User.first(2)
  users.each_with_index do |user, index|
    case (index % 2)
    when 0
      my_boats = boats[0...3]
    when 1
      my_boats = boats[4...6]
    when 2
      my_boats = boats[7...9]
    end
    my_boats.each do |boat|
      specs = ""
      boat["specs"].each { |k, v| specs << "#{k}: #{v}\n" }
      equipment = ""
      boat["equipment"].each { |k, v| equipment << "#{k}: #{v}\n" }
      new_boat = user.boats.new(
      boat_type: boat["type"],
      name: boat["name"],
      city: boat["city"],
      capacity: boat["capacity"],
      description: boat["description"],
      specs: specs,
      equipment: equipment,
      day_rate: boat["day_rate"]
      )
      new_boat.save
    end
  end
end

# Doesn't work
def seed_bookings
  Boat.all.each do |boat|
    rand(1..3).times do
      Booking.new(
      boat_id: boat,
      user_id: nil,
      start_at: nil,
      end_at: nil,
      user_review: nil,
      owner_review: nil,
      user_rating: nil,
      owner_rating: nil,
      validated_at: nil
      )
    end
  end
end

# Seed availabilities

puts "Have you created at least one user? [y/n]"
input = STDIN.gets.chomp

if input == "y"
  if User.count < 1
    puts "Liar."
  else
    seed_boats
  end
else
  puts("Then go create one first, dumbass.")
end
