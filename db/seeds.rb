MODELS = [User, Boat, Availability, Booking]

def delete_seed
  typeset_title("Deleting seed", "light_red")
  models_to_destroy = MODELS.reverse.map { |m| prompt_user(m, "delete all")}
  delete(models_to_destroy)
end

def create_seed
  typeset_title("Creating seed", "light_green")
  models_to_create = MODELS.map { |m| prompt_user(m, "create new")}
  seed(models_to_create)
end

def delete(boolean_array)
  if boolean_array.include?(true)
    MODELS.reverse.each_with_index do |m, i|
      if boolean_array[i]
        typeset("#{m.count} #{m.name}s deleted.\n".light_red)
        m.destroy_all
      end
    end
  else
    typeset("Seed was spared. Phew !\n".light_yellow)
  end
end

def seed(boolean_array)
  if boolean_array.include?(true)
    boolean_array.each_with_index do |boolean, index|
      case index
      when 0
        if boolean
          seed_users(prompt_for_user_number)
        end
      when 1
        if boolean
          typeset_title("Seeding boats", "light_green")
          if User.count < 1
            typeset("You need to create users before creating boats !\n".light_magenta)
          else
            json_file = prompt_for_json_file
            seed_boats(json_file)
          end
        end
      when 2
        if boolean
          typeset_title("Seeding availabilities", "light_green")
          inform_not_available
        end
      when 3
        if boolean
          typeset_title("Seeding bookings", "light_green")
          inform_not_available
        end
      end
    end
  else
    typeset("No seed was created. Booo...\n".light_yellow)
  end
end

def seed_users(number)
  number.times do |i|
    user = User.new(
    email: Faker::Internet.email,
    password: 'theorules',
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    phone_number: Faker::PhoneNumber.cell_phone,
    boat_license: [true, false].sample
    )
    if user.save
      puts "#{i} - Created: #{user.first_name}".light_yellow
    else
      puts "Error creating user"
    end
  end
end

def seed_boats(json_filepath)
  number = -1
  while number < 0 || number > User.count
    typeset("\nYou have #{User.count} users\n".light_yellow)
    typeset("How many of them would you like to attribute boats to?\n".light_cyan)
    print "> "
    number = STDIN.gets.chomp.to_i
  end
  users = User.order("RANDOM()").limit(number)
  boats = JSON.parse(File.read(json_filepath))
  while boats.empty? == false
    boats.each do |index, boat|
      owner = users.sample
      new_boat = owner.boats.new

      specs = ""
      boat["specs"].each { |k, v| specs << "#{k}: #{v}\n" }
      equipment = ""
      boat["equipment"].each { |k, v| equipment << "#{k}: #{v}\n" }

      new_boat.update(
      boat_type: boat["type"],
      length: boat["length"],
      name: boat["name"],
      city: boat["city"],
      capacity: boat["capacity"],
      beds: boat["beds"],
      image1: boat["images"][0],
      image2: boat["images"][1],
      image3: boat["images"][2],
      description: boat["description"],
      specs: specs,
      equipment: equipment,
      day_rate: boat["day_rate"]
      )
      boats.delete(index)
      puts "#{owner.first_name}".light_yellow + " got " + "#{new_boat.name}!".light_cyan + "                  \r"
    end
  end
  sleep(2)
end

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

def prompt_user(model, action)
  info = "#{model.count} #{model.name.downcase}s in database - "
  action == "delete all" ? action = action.upcase.light_red : action = action.upcase.light_green
  prompt = " ? [y/n] "
  print info + action + prompt
  answer = STDIN.gets.chomp
  answer == "y"
end

def prompt_for_user_number
  typeset_title("Seeding users", "light_green")
  typeset("How many users would you like to create?\n".light_cyan)
  print "> "
  STDIN.gets.chomp.to_i
end

def prompt_for_json_file
  ignore = "db/samboat_urls_all_boats.json"
  json_files = Dir["db/*.json"].reject { |f| f == ignore }
  index = -1
  while index < 0 || index > json_files.length
    typeset("Which JSON file woud you like to seed from?\n".light_cyan)
    json_files.each_with_index { |f, i| puts "#{i.to_s.red} - #{f}" }
    print "> "
    index = STDIN.gets.chomp.to_i
  end
  json_files[index]
end

def inform_not_available
  typeset("Feature hasn't been coded yet :(\n".light_magenta)
  sleep(0.5)
end

def typeset(string)
  string.each_char { |chr| print chr ; sleep(0.027) }
end

def typeset_title(string, color)
  case color
  when "light_green" then typeset("\n-- #{string} --\n\n".light_green)
  when "light_red" then typeset("\n-- #{string} --\n\n".light_red)
  end
end

def get_feedback
  typeset("\nAre you happy ? [y/n] ".light_cyan)
  answer = STDIN.gets.chomp
  if answer == "y"
    puts ""
    typeset("Thank you for using JooLeeAnh's Express Seeding services !\n\n".light_yellow)
    sleep(2)
  else
    sleep(1)
    typeset("\nFuck you\n\n".red)
    sleep(0.2)
  end
end

typeset("\nWelcome to JooLeeAnh's Express Seeding services !\n".light_yellow)
delete_seed
create_seed
typeset("\nSeeding done :)\n".light_green)
get_feedback
