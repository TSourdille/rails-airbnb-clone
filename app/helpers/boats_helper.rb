module BoatsHelper

  def clean_up_string_array(specs)
    # returns e.g. [["Localité", "Le Ferré, France"], ["Emplacement", "Stockage à sec"], ...]
    specs.split("\n").map {|s| s.split(": ")}.map {|b| [b[0].gsub("-", "'").gsub("_"," "), b[1]]}
  end

  def apply_booleans(equipment)
    equip = equipment[0].tr("?", "")
    if equipment[1] == "false"
      equip = "<s class='boat-spec-strike'>" + equip + "</s>"
    end
    equip
  end

  def split_in_half(specs, half)
    case half
    when 1 then specs = specs.select.with_index { |s, i| i <= (specs.count)/2 }
    when 2 then specs = specs.select.with_index { |s, i| i > (specs.count)/2 }
    end
    specs
  end

  def get_non_owner_user(owner)
    User.where.not(id: owner.id).offset(rand(User.count-1)).first
  end

  def bookings_with_reviews(boat)
    boat.bookings.where.not(user_review: nil)
  end

  def split_on_lines(text)
    text.split("\n").map { |t| "<p>" + t + "</p>" }.join("").html_safe
  end

  def boat_pictures(boat)
    if boat.photos?
      photos = boat.photos
    elsif boat.image1.presence
      photos = [boat.image1]
      photos << boat.image2 if boat.image2.presence
      photos << boat.image3 if boat.image3.presence
    else
      photos = ["blank-boat-picture.svg"]
    end
    photos
  end

  def boat_avg_ratings(bookings)
    rating_total = bookings.map { |b| b.user_rating }.reject { |r| r.nil? }
    rating_total.reduce(:+) / (rating_total.count)
  end
end
