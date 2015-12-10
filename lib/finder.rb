require_relative '../models'

class Finder

  def date_find(street_raw, house_raw)
    street = normalize_street(street_raw)
    house = normalize_house(house_raw)
    result = 
      if (!(Address[street: street].nil?) && Address[street: street].house == '*')
       Address[street: street].offdate.date
      elsif Address[street: street, house: house].nil?
       'Нет информации'
      else 
       Address[street: street, house: house].offdate.date
      end
    result
  end

  private

  def normalize_street(street)
    street.gsub!('ё', 'е')
    case
    when street.include?('проспект')
      street = 'проспект ' + street.sub('проспект', '').strip
    when street.include?('переулок')
      street = 'переулок ' + street.sub('переулок', '').strip
    when street.include?('улица')
      street = street.sub('улица', '').strip
    end
    street
  end

  def normalize_house(house)
     house.include?('-') ? house.split('-')[0] : house
  end

end #class
