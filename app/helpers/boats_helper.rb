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
end
