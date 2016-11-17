MODELS = [User, Boat, Booking]

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
        if m.name == "User"
          fake_users = User.all.reject { |u| u.photo? || u.facebook_picture_url }
          custom_users = User.all.select { |u| u.photo? || u.facebook_picture_url }
          database = "\n#{custom_users.count} custom users in database - ".light_yellow
          action = "DELETE ALL".light_red
          prompt = " ? [y/n] "
          puts database + action + prompt
          answer = (STDIN.gets.chomp == "y")
          if answer
            typeset("#{m.count} #{m.name}s deleted.\n".light_red)
            m.destroy_all
          else
            typeset("#{fake_users.count} #{m.name}s deleted.\n".light_red)
            fake_users.each do |u|
              u.destroy
            end
          end
        else
          typeset("#{m.count} #{m.name}s deleted.\n".light_red)
          m.destroy_all
        end
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
          json_file = prompt_for_json_file("randomuser")
          seed_users(json_file, prompt_for_user_number)
        end
      when 1
        if boolean
          typeset_title("Seeding boats", "light_green")
          if User.count < 1
            typeset("You need to create users before creating boats !\n".light_magenta)
          else
            json_file = prompt_for_json_file("samboat")
            seed_boats(json_file)
          end
        end
      when 2
        if boolean
          typeset_title("Seeding bookings", "light_green")
          seed_bookings
        end
      end
    end
  else
    typeset("No seed was created. Booo...\n".light_yellow)
  end
end

def seed_users(json_file, number)
  users = JSON.parse(File.read(json_file))
  number.times do |i|
    u = users["#{i}"]
    user = User.new(
    first_name: u["first_name"].capitalize,
    last_name: u["last_name"].capitalize,
    country: u["country"].capitalize,
    email: u["email"],
    password: "sailaway",
    registered_at: u["registered"].to_date,
    phone_number: u["phone"],
    picture_url: u["photo_large"],
    avatar_url: u["photo_thumbnail"],
    boat_license: [true, false].sample
    )
    if user.save
      puts "#{i} - Created: #{user.country} - #{user.first_name}".light_yellow
    else
      puts "Error creating user"
    end
  end
end

def seed_boats(json_filepath)
  boats = JSON.parse(File.read(json_filepath))
  number = -1
  while number < 1 || number > User.count
    typeset("\nYou have #{User.count} users\n".light_yellow)
    typeset("How many of them would you like to attribute boats to?\n".light_cyan)
    print "> "
    number = STDIN.gets.chomp.to_i
  end
  number_boats = -1
  while number_boats < 1 || number_boats > boats.count
    typeset("How many boats to attribute in total? (#{boats.count} boats total)\n".light_cyan)
    print "> "
    number_boats = STDIN.gets.chomp.to_i
  end
  users = User.order("RANDOM()").limit(number)
  boats = boats.select { |k, v| k.to_i < number_boats }
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
  boat_ids_reviews = boats_with_reviews
  answers = prompt_booking_past_future
  create_boat_bookings(boat_ids_reviews, -1) if answers[:past] == "y"
  create_boat_bookings(boat_ids_reviews, 1) if answers[:future] == "y"
end

def boats_with_reviews
  json_filepath = prompt_for_json_file("samboat")
  JSON.parse(File.read(json_filepath)).reject { |k, v| v["reviews"].empty? || v["reviews"].nil? }
end

def create_boat_bookings(boats, past_future)
  boat_ids = boats.map { |k, v| k.to_s }
  Boat.all.each do |boat|
    boat_id = boat_ids.sample
    boat_ids.delete(boat_id)
    reviews = boats[boat_id]["reviews"]
    reviews = reviews.to_a
    random_number = rand(1...5)
    random_number.times do
      random_user = User.offset(rand(0..User.count-1)).first
      random_date_start_offset = Date.today + rand(1..20) * past_future
      random_date_end_offset = random_date_start_offset + rand(1..7)
      if past_future == 1 || reviews.empty? || random_date_end_offset > Date.today
        review_desc = nil
        review_rating = nil
      else
        review = reviews.sample
        review_desc = review["description"]
        review_rating = review["rating"]
        reviews.delete(review)
      end
      boat.bookings.create(
      user_id: random_user.id,
      start_at: random_date_start_offset,
      end_at: random_date_end_offset,
      user_review: review_desc,
      owner_review: nil,
      user_rating: review_rating,
      owner_rating: nil,
      validated_at: nil
      )
      print "#{Booking.last.boat.name}".light_yellow + " - " + "#{Booking.last.user_rating}".light_cyan + "                  \r"
    end
  end
end

def prompt_booking_past_future
  answers = {}
  typeset("\nSeed bookings in the PAST? [y/n] ".light_cyan)
  answers[:past] = STDIN.gets.chomp
  typeset("\nSeed bookings in the FUTURE? [y/n] ".light_cyan)
  answers[:future] = STDIN.gets.chomp
  answers
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

def prompt_for_json_file(prefix)
  ignore = "db/samboat_urls_all_boats.json"
  json_files = Dir["db/#{prefix}*.json"].reject { |f| f == ignore }
  index = -1
  while index < 0 || index > json_files.length
    typeset("\nWhich JSON file woud you like to seed from?\n".light_cyan)
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
  string.each_char { |chr| print chr ; sleep(0.023) }
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
    sleep(1)
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
