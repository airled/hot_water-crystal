require 'nokogiri'
require 'curb'
require_relative '../models'

class Parser

  def run
    puts 'Begin parsing...'
    quantity_start = Address.count
    source = 'http://www.belta.by/regions/view/grafik-otkljuchenija-gorjachej-vody-v-minske-v-2015-godu-153269-2015/'
    html = fetch_html(source)
    #parse second part of the page
    second_part(p_tags(html))
    streets_strong = streets_from_strongs(html)
    #parse first part of the page
    first_part(html, streets_strong)
    quantity_stop = Address.count
    puts "Parsed. Records created: #{quantity_stop - quantity_start}. Addresses total: #{quantity_stop}"
  end

  private

  def fetch_html(source)
    Nokogiri::HTML(Curl.get(source).body)
  end

  def create_offdate(date)
    Offdate.create(date: date)
  end

  #normilize street name
  def checked(street)
    case
    when street.split(' ').last == 'пер'
      street = 'переулок ' + street.reverse.split(' ').drop(1).join.reverse
    when street.split(' ').last == 'пр'
      street = 'проспект ' + street.reverse.split(' ').drop(1).join.reverse
    when !(street.scan('пер.').empty?)
      street = 'переулок ' + street.sub('пер.', '')
    when !(street.scan(/пр-т|пр-т./).empty?)
      street = 'проспект ' + street.sub(/пр-т|пр-т./, '')
    end
    street
  end

  #collect all the <p> from the page in an array
  def p_tags(html)
    p_array = []
    html.xpath('//div[@class="center_col"]/p').map do |p_tag|
      (p_array << p_tag.text.gsub(/у потребителей по улицам:|;/, '').gsub('в период', 'В период').strip) unless p_tag.text.match(/[А-Яа-я]/).nil?
    end
    p_array
  end

  #take <p>-array and build hash from it
  #hash looks like {date1 => block_for_date1, date2 => block_for_date2}
  def second_part(array)
    main_hash = {}
    date = ''
    array.each do |value|
      if value.include?('В период')
        date = value.gsub(/[^А-Яа-я0-9\ ]|В период /, '')
        main_hash.merge!(date => [])
      else
        main_hash[date] << value.strip
      end
    end

    #take date from main hash, save it in the database
    3.times { main_hash.shift }
    main_hash.each do |key, value|
      offdate = create_offdate(key)
      #split value in street and houses for the street
      value.map do |part|
        splitted_line = part.split(',')
        street = splitted_line[0]
        splitted_line.drop(1).map do |houses|
          extend_range(houses).map do |house|
            offdate.add_address(street: checked(street), house: house.to_s.strip)
          end
        end
      end
    end
  end #def
  
  def streets_from_strongs(html)
    streets = []
    html.xpath('//div[@class="center_col"]//strong').map do |strong|
      streets << strong.text unless (strong.text.include?('В период') || strong.text.include?('в период') || strong.text == '')
    end
    streets
  end

  #extend range like 1-5 to 1,3,5
  #                  2-6 to 2,4,6
  #                  1-6 to 1,2,3,4,5,6
  def extend_range(range)
    if range.include?('-') && !(range.include?('к'))
      start = range.split('-')[0].to_i
      stop = range.split('-')[1].to_i
      if (stop - start).odd?
        (start..stop).to_a
      else
        (start..stop).step(2).to_a
      end
    else
      [range]
    end
  end

  def first_part(html, streets)
    divider = 'График отключения горячей воды в Минске на август будет доступен после 15 июля.'
    first_part_text = html.xpath('//div[@class="center_col"]').text.strip.split(divider)[0]
    #main is [ date_with_address_group1, date_with_address_group2... ]
    main = first_part_text.split('В период').drop(1)

    dates = []
    date_blocks = []

    main.map do |date_part|
      dates << date_part.split(' у потребителей по улицам')[0].strip
      date_blocks << date_part.split(' у потребителей по улицам')[1].strip
    end
    #streets_blocks is [ [street1,street2,street3], [street4,street5,street6]... ]
    #                    {         date1         }  {         date2         }
    streets_blocks = []
    date_blocks.map do |date_block|
      matched_streets = []
      streets.map.with_index do |street, index|
        if date_block.include?(street)
          matched_streets << street
          date_block.sub!(street, '!!!')
          streets[index] = '@'
        end
      end
      streets_blocks << matched_streets
    end
    #houses_blocks is [ [houses1, houses2, houses3], [houses4, houses5, houses6]... ]
    #                   {street1}{street2}{street3}  {street4}{street5}{street6}
    #                   {          date1          }  {          date2          }
    houses_blocks = date_blocks.map { |date_block| date_block.gsub(';', ',').split('!!!').drop(1) }

    dates.zip(streets_blocks, houses_blocks).map do |date, streets_block, houses_block|
      offdate = create_offdate(date)
      streets_block.zip(houses_block).map do |street, houses|
        case
        when houses.scan(/[0-9А-Яа-я]/).empty?
          houses = '*'
        when houses[0] == ','
          houses[0] = ' '
        end
        houses = houses.gsub(' – ', '-').strip.gsub(/[^0-9А-Яа-я*()\ ][^0-9А-Яа-я*()\ ]/, '')
        houses.split(',').map do |houses_part|
          if houses_part =~ /[0-9]+-[0-9]+/
            extend_range(houses_part).map do |house|
              offdate.add_address(street: checked(street), house: house.to_s.strip)
            end
          else 
            offdate.add_address(street: checked(street), house: houses_part.strip)
          end
        end
      end
    end
  end

end #class
