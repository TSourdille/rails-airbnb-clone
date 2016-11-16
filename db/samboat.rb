require 'nokogiri'
require 'colorize'
require "json"
require "open-uri"
require "pry-byebug"

class SamboatScraper
  attr_reader :boats
  def initialize
    @boats = {}
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

  def scrape_boat(noko_boat, boat_url, stats)
    boat = {}
    boat[:url] = boat_url
    boat[:name] = noko_boat.css('.block-100 h1').text
    parse_city_type_capacity(noko_boat, boat)
    boat[:images] = parse_images(noko_boat)
    boat[:description] = noko_boat.css('#desc p').text
    boat[:day_rate] = noko_boat.css('.table-responsive table:first tbody tr:first td:first').text
    boat[:specs] = parse_specs(noko_boat)
    boat[:equipment] = parse_equipment(noko_boat)
    boat[:reviews] = parse_reviews(noko_boat)
    clean_up(boat)
    @boats[stats[:index]] = boat
    display_boat_name(boat, stats)
  end

  def store_json(array, stats)
    filepath = "db/samboat_#{stats[:start]}to#{stats[:end]}_#{array}" + Time.now.strftime('_%Y%m%d%H%M')
    File.open(filepath + '.json', 'w') do |file|
      file.write(JSON.generate(@boats))
    end
  end

  private

  def display_boat_name(boat, stats)
    s = "#{stats[:index]} - #{stats[:start]+stats[:index]}/#{stats[:end]} - #{boat[:name]}".gsub(/\n|\r/, "")
    print s + "                                    \r"
  end

  def clean_up(hash)
    hash.each do |k, v|
      clean_up(v) if v.is_a?(Hash)
      begin
        hash[k] = v.strip
      rescue
      end
    end
  end

  def parse_city_type_capacity(noko_boat, boat)
    begin
      noko_boat.css('.item-overview-bateau').each_with_index do |b, i|
        case i
        when 0
          boat[:city] = b.text
        when 1
          text = b.text.split(", ")
          boat[:type] = text[0]
          boat[:length] = text[1]
        when 2
          text = b.text.split(", ")
          boat[:capacity] = text[0]
          boat[:beds] = text[1]
        end
      end
    rescue
    end
  end
  def parse_images(noko_boat)
    images = []
    begin
      noko_boat.css('.container-slider > div:nth-child(1) > div:not(:first)').each do |image|
        images << image.css('img:first').attribute('src').text
      end
    rescue
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
    rescue
    end
    specs
  end
  def parse_reviews(noko_boat)
    reviews = []
    begin
      noko_boat.css('#avis .row').each do |rev|
        review = {}
        rating = 5
        review[:description] = rev.css('.p-membre-avis:last-child').text
        rev.css('.block-100 i').each do |star|
          rating -= 1 if star.attribute('class').value.include?('fa fa-star-o')
        end
        review[:rating] = rating
        reviews << review
      end
    rescue
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
    rescue
    end
    equipments
  end
end


def cool_boats
  [
    "https://www.samboat.fr/location-bateau/cannes/bateau-a-moteur/1309",
    "https://www.samboat.fr/location-bateau/empuriabrava/semi-rigide/8787",
    "https://www.samboat.fr/location-bateau/santa-maria-poggio/bateau-a-moteur/14734",
    "https://www.samboat.fr/location-bateau/cap-dagde-le/bateau-a-moteur/9785",
    "https://www.samboat.fr/location-bateau/le-marin-martinique/multicoque/2941",
    "https://www.samboat.fr/location-bateau/le-marin-martinique/multicoque/2946",
    "https://www.samboat.fr/location-bateau/nice/multicoque/1089",
    "https://www.samboat.fr/location-bateau/ajaccio/voilier/2427",
    "https://www.samboat.fr/location-bateau/ajaccio/bateau-a-moteur/2494",
    "https://www.samboat.fr/location-bateau/saint-tropez/bateau-a-moteur/1685",
    "https://www.samboat.fr/location-bateau/cogolin/semi-rigide/14997",
    "https://www.samboat.fr/location-bateau/arzon/voilier/10211",
    "https://www.samboat.fr/location-bateau/porto-vecchio/bateau-a-moteur/9445",
    "https://www.samboat.fr/location-bateau/treauville/multicoque/2927",
    "https://www.samboat.fr/location-bateau/ajaccio/voilier/2430",
    "https://www.samboat.fr/location-bateau/horta/voilier/8652",
    "https://www.samboat.fr/location-bateau/ajaccio/semi-rigide/3083",
    "https://www.samboat.fr/location-bateau/saint-florent/semi-rigide/2098",
    "https://www.samboat.fr/location-bateau/vermenton/peniche/10771"
  ]
end
def all_boats
  JSON.parse(File.read("db/samboat_urls_all_boats.json")).map { |b| b["url"] }
end

CHOICES = [{cool_boats: cool_boats}, {all_boats: all_boats}]
answer = -1
while answer < 0 || answer > CHOICES.length
  puts "Which boats would you like to parse?"
  CHOICES.each_with_index { |e, i| puts "#{i} - #{e.keys.first}" }
  answer = gets.chomp.to_i
end

case answer
when 0 then
  boats = CHOICES[answer].values.first
when 1 then
  boats = CHOICES[answer].values.first
end

r_start = -1
r_end = -1
while r_start < 0 || r_start > r_end || r_end > boats.size
  puts "What range do you want to parse? (0 - #{boats.size - 1})"
  print "start> "
  r_start = gets.chomp.to_i
  print "end> "
  r_end = gets.chomp.to_i
end
r_count = r_end - r_start
boats = boats[r_start..r_end]

sam = SamboatScraper.new

boats.each_with_index do |boat_url, index|
  stats = {start: r_start, end: r_end, count: r_count, index: index}
  noko_boat = Nokogiri::HTML(open(boat_url))
  sam.scrape_boat(noko_boat, boat_url, stats)
end

sam.store_json(CHOICES[answer].keys.first, {start: r_start, end: r_end})

puts "\n\nDone".green
