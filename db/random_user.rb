require "json"
require 'rest-client'
require "pry-byebug"
require "iso_country_codes"

class RandomUser
  attr_reader :users

  def initialize
    @users = {}
  end
  def parse_users(random_user_url, index)
    json_doc = JSON.parse(RestClient.get(random_user_url))
    json_doc["results"].each do |json|
      user = {}
      user = {
        gender: json["gender"],
        title: json["name"]["title"],
        first_name: json["name"]["first"],
        last_name: json["name"]["last"],
        street: json["location"]["street"],
        city: json["location"]["city"],
        state: json["location"]["state"],
        postcode: json["location"]["postcode"],
        country: IsoCountryCodes.find(json["nat"]).name,
        email: json["email"],
        username: json["login"]["username"],
        password: json["login"]["password"],
        dob: json["dob"],
        registered: json["registered"],
        phone: json["phone"],
        cell: json["cell"],
        photo_large: json["picture"]["large"],
        photo_medium: json["picture"]["medium"],
        photo_thumbnail: json["picture"]["thumbnail"],
        nat: json["nat"]
      }
      @users[index] = user
      index += 1
    end
    puts "@users contains #{@users.count} users."
    index
  end

  def store_json(number)
    filepath = "db/randomuser_#{number}" + Time.now.strftime('_%Y%m%d%H%M')
    File.open(filepath + '.json', 'w') do |file|
      file.write(JSON.generate(@users))
    end
  end
end

random_user = RandomUser.new

def countries
  [
    "FR",
    "ES",
    "CH",
    "DE",
    "GB",
    "IE",
    "DK",
    "NL",
    "NZ",
    "US",
    "CA"
  ]
end

number = 0
index = 0
countries.each do |country|
  break if number == -1
  number = -2
  while number < -1 || number > 100
    puts "How many #{country} users would you like to generate? (enter -1 to stop and store)"
    number = gets.chomp.to_i
  end
  random_user_url = "https://randomuser.me/api/?nat=#{country}&results=#{number}"
  index = random_user.parse_users(random_user_url, index) unless number < 1
end

random_user.store_json(index)
