require 'nokogiri'
require 'colorize'
require "json"
require "open-uri"
require "pry-byebug"

class SamboatScraper
  attr_reader :boats
  def initialize(boats)
    @boats = boats || []
  end

  def scrape_boats
    305.times do |i|
      url = "https://www.samboat.fr/location-bateau?&page=#{i+1}"
      nokodoc = Nokogiri::HTML(open(url))
      nokodoc.search('.annonce_boat').each do |annonce|
        boat = {}
        begin
          boat[:original_id] = annonce.attribute('id').text
          display_success("original_id")
        rescue
          display_error("original_id")
        end
        begin
          boat[:url] = annonce.attribute('data-url').text
          display_success("url")
        rescue
          display_error("url")
        end
        @boats << boat
        puts "#{i} - #{boat[:url]}"
      end
    end
  end

  def scrape_boat(noko_boat, boat, index, errors)
    boat[:original_id] = boat["original_id"]
    boat.delete("original_id")
    boat[:url] = boat["url"]
    boat.delete("url")
    begin
      boat[:name] = noko_boat.css('.block-100 h1').text
      display_success(:name)
    rescue
      errors[:name] += 1
      display_error(:name)
    end
    parse_city_type_capacity(noko_boat, boat)
    begin
      boat[:images] = parse_images(noko_boat)
      display_success(:images)
    rescue
      errors[:images] += 1
      display_error(:images)
    end
    begin
      boat[:description] = noko_boat.css('#desc p').text.strip
      display_success(:description)
    rescue
      errors[:description] += 1
      display_error(:description)
    end
    begin
      boat[:day_rate] = noko_boat.css('.table-responsive tbody tr:first td:first').text
      display_success(:day_rate)
    rescue
      errors[:day_rate] += 1
      display_error(:day_rate)
    end
    begin
      boat[:specs] = parse_specs(noko_boat)
      display_success(:specs)
    rescue
      errors[:specs] += 1
      display_error(:specs)
    end
    begin
      boat[:equipment] = parse_equipment(noko_boat)
      display_success(:equipment)
    rescue
      errors[:equipment] += 1
      display_error(:equipment)
    end
    begin
      boat[:reviews] = parse_reviews(noko_boat)
      display_success(:reviews)
    rescue
      errors[:reviews] += 1
      display_error(:reviews)
    end
    display_headers(errors) if index % 20 == 0
    display_parsing_full(boat, errors)
  end

  def store_json
    filepath = Time.now.strftime('db/samboat_%Y-%m-%d-%H-%M')
    File.open(filepath + '.json', 'w') do |file|
      file.write(JSON.generate(@boats))
    end
  end

  private

  def display_error(key)
    # puts "Parsing error for #{key}".light_red
  end
  def display_success(key)
    # puts "Parsing success for #{key}".light_green
  end
  def display_headers(hash)
    print "|".green
    hash.each do |k, v|
      print " #{k} |"
    end
    puts ""
  end
  def display_parsing_summary(boat)
    puts "#{boat[:city].light_cyan} - #{boat[:original_id].magenta} - #{boat[:name].light_blue} - Parsing complete"
  end
  def display_parsing_full(hash, errors)
    hash.each do |key, value|
      print "|"
      case key
      when :original_id
        print ""
        value.nil? ? print(('%-12.12s' % value).green) : print(('%-12.12s' % value).green)
        print " "
      when :url
        print "  "
        value.nil? ? print("E".light_red) : print("S".green)
        print "  "
      when :name
        print "  "
        value.nil? ? print("E".light_red) : print("S".green)
        print "   "
      when :city
        print "  "
        value.nil? ? print("E".light_red) : print("S".green)
        print "   "
      when :type
        print "  "
        value.nil? ? print("E".light_red) : print("S".green)
        print "   "
      when :capacity
        print "    "
        value.nil? ? print("E".light_red) : print("S".green)
        print "     "
      when :images
        print "   "
        value.nil? ? print("E".light_red) : print("S".green)
        print "    "
      when :description
        print "      "
        value.nil? ? print("E".light_red) : print("S".green)
        print "      "
      when :day_rate
        print "     "
        value.nil? ? print("E".light_red) : print("S".green)
        print "    "
      when :specs
        print "   "
        value.nil? ? print("E".light_red) : print("S".green)
        print "   "
      when :equipment
        print "     "
        value.nil? ? print("E".light_red) : print("S".green)
        print "     "
      when :reviews
        print "    "
        value.nil? ? print("E".light_red) : print("S".green)
        print "    "
      end
    end
    print "|"
    print "  "
    print ('%-6.6s' % (Time.now - errors[:time_elapsed]).round(1))
    print "   "
    puts "|"
  end

  def parse_city_type_capacity(noko_boat, boat)
    begin
      noko_boat.css('.item-overview-bateau').each_with_index do |b, i|
        case i
        when 0
          boat[:city] = b.text
        when 1
          boat[:type] = b.text
        when 2
          boat[:capacity] = b.text
        end
      end
      display_success(:city)
    rescue
      errors[:city_type_capacity] += 1
      display_error(:city_type_capacity)
    end
  end
  def parse_images(noko_boat)
    images = []
    begin
      noko_boat.css('.container-slider > div:nth-child(1) > div:not(:first)').each do |image|
        images << image.css('img:first').attribute('src').text
      end
      display_success(:images)
    rescue
      errors[:images] += 1
      display_error(:images)
    end
    images
  end
  def parse_specs(noko_boat)
    specs = {}
    begin
      noko_boat.css('#desc div:nth-child(4) > .col-md-4').each do |column|
        column.css('.item-specification-bateau').each do |spec|
          header = spec.css('strong').text
          data = spec.text.gsub(header, "").strip.gsub(/\n\s{2,}/, "\n")
          header = header.gsub(" : ", "").gsub(" :", "").gsub(/\s/, "_").gsub(/'/, "-")
          specs[header.to_sym] = data
        end
      end
      display_success(:specs)
    rescue
      errors[:specs] += 1
      display_error(:specs)
    end
    specs
  end
  def parse_reviews(noko_boat)
    reviews = []
    begin
      noko_boat.css('#avis .row').each do |rev|
        review = {}
        rating = 5
        review[:description] = rev.css('.p-membre-avis:last-child').text.strip
        rev.css('.block-100 i').each do |star|
          rating -= 1 if star.attribute('class').value.include?('fa fa-star-o')
        end
        review[:rating] = rating
        reviews << review
      end
      display_success(:reviews)
    rescue
      errors[:reviews] += 1
      display_error(:reviews)
    end
    reviews
  end
  def parse_equipment(noko_boat)
    equipments = {}
    begin
      noko_boat.css('#equipements .item-equipement-bateau').each do |equipment|
        header = equipment.text
        boolean = equipment.attribute('class').value.include?('unavailable')
        equipments[(header + "?").gsub(" ", "_").to_sym] = !boolean
      end
      display_success(:equipment)
    rescue
      errors[:equipment] += 1
      display_error(:equipment)
    end
    equipments
  end
end

boats = JSON.parse(File.read("db/samboat_urls_all_boats.json"))
errors = { original_id: 0, url: 0, name: 0, city: 0, type: 0, capacity: 0, images: 0, description: 0, day_rate: 0, specs: 0, equipment: 0, reviews: 0, time_elapsed: Time.now }

sam = SamboatScraper.new(boats)
# sam.scrape_boats
# sam.store_json

puts "How many boats?"
count = gets.chomp.to_i

boats = sam.boats.first(count)
boats.each_with_index do |boat, index|
  noko_boat = Nokogiri::HTML(open(boat["url"]))
  sam.scrape_boat(noko_boat, boat, index, errors)
end

# sam.boats.each_with_index do |boat, index|
#   noko_boat = Nokogiri::HTML(open(boat["url"]))
#   sam.scrape_boat(noko_boat, boat, index, errors)
# end

sam.store_json

puts "Done".green
