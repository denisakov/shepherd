namespace :crawl do
  desc "collects and updates data from external sources"
  task :owner, [:imo] => :environment do |t, args|
    require 'rubygems'
    require 'open-uri'
    require 'roo'
    require 'mechanize'

    LOWER_SINGLE = {
			"і"=>"i","ґ"=>"g","ё"=>"yo","№"=>"#","є"=>"e",
			"ї"=>"yi","а"=>"a","б"=>"b",
			"в"=>"v","г"=>"g","д"=>"d","е"=>"e","ж"=>"zh",
			"з"=>"z","и"=>"i","й"=>"y","к"=>"k","л"=>"l",
			"м"=>"m","н"=>"n","о"=>"o","п"=>"p","р"=>"r",
			"с"=>"s","т"=>"t","у"=>"u","ф"=>"f","х"=>"h",
			"ц"=>"ts","ч"=>"ch","ш"=>"sh","щ"=>"sch","ъ"=>"'",
			"ы"=>"y","ь"=>"","э"=>"e","ю"=>"yu","я"=>"ya",
		}
		LOWER_MULTI = {
			"ье"=>"ie",
			"ьё"=>"ie",
		}
		UPPER_SINGLE = {
			"Ґ"=>"G","Ё"=>"YO","Є"=>"E","Ї"=>"YI","І"=>"I",
			"А"=>"A","Б"=>"B","В"=>"V","Г"=>"G",
			"Д"=>"D","Е"=>"E","Ж"=>"ZH","З"=>"Z","И"=>"I",
			"Й"=>"Y","К"=>"K","Л"=>"L","М"=>"M","Н"=>"N",
			"О"=>"O","П"=>"P","Р"=>"R","С"=>"S","Т"=>"T",
			"У"=>"U","Ф"=>"F","Х"=>"H","Ц"=>"TS","Ч"=>"CH",
			"Ш"=>"SH","Щ"=>"SCH","Ъ"=>"'","Ы"=>"Y","Ь"=>"",
			"Э"=>"E","Ю"=>"YU","Я"=>"YA",
		}
		UPPER_MULTI = {
			"ЬЕ"=>"IE",
			"ЬЁ"=>"IE",
		}
		LOWER = (LOWER_SINGLE.merge(LOWER_MULTI)).freeze
		UPPER = (UPPER_SINGLE.merge(UPPER_MULTI)).freeze
		MULTI_KEYS = (LOWER_MULTI.merge(UPPER_MULTI)).keys.sort_by {|s| s.length}.reverse.freeze

    # Возвращает строку, в которой все буквы русского алфавита заменены на похожую по звучанию латиницу
	def translit(str)
		chars = str.scan(%r{#{MULTI_KEYS.join '|'}|\w|.})
		result = ""
		chars.each_with_index do |char, index|
			if UPPER.has_key?(char) && LOWER.has_key?(chars[index+1])
				# combined case
				result << UPPER[char].downcase.capitalize
			elsif UPPER.has_key?(char)
				result << UPPER[char]
			elsif LOWER.has_key?(char)
				result << LOWER[char]
			else
				result << char
			end
		end
		result
	end

    agent = Mechanize.new
	agent.user_agent_alias = 'Windows Mozilla'
		
    if args.count == 0
    	puts ''
    	puts "Seems like the IMO number wasn't provided, so we will go trough all vessels"
    	puts ''

    	vimo = Array.new
    	#Vessel.all.each
		Vessel.where('owner_id is ?', nil).each do |v|
			vimo << v.imo
		end

		vimo.each do |imo|
			if !imo.nil?

				v = Vessel.find_by_imo(imo)

				puts " "
				puts "We will be looking for the OWNER of vessel #{v.vsl_name}."
				puts " "

				url = "http://fleetphoto.ru/ajax2.php?action=index-qsearch&num=&exact=0&imo=" + imo + "&mmsi="
				
				puts url
				
				page = open(url,'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.874.121 Safari/535.2').read
				puts "Loaded first page..."
				sleep rand(4..7)
				if page.length > 2
					puts "Page has content"
					fleet_ref = page[9..13].gsub("\"","").gsub(",","")
					puts "The reference number is #{fleet_ref}"
					url = "http://fleetphoto.ru/ship/" + fleet_ref + "/"
					puts "Opening #{url}"
					begin
						agent.get(url)
						puts "Page loaded. Searching for the owner name"

						found_owner_full = agent.page.search('.s1 td:contains("Владелец")')[0] || agent.page.search('.s11 td:contains("Владелец")')[0]
						if found_owner_full.nil?
							found_owner_full = agent.page.search('.s1 td:contains("Владелец и оператор")')[0] || agent.page.search('.s11 td:contains("Владелец и оператор")')[0]
						end
						if !found_owner_full.nil?
							found_owner = found_owner_full.parent.children[1].text[0..-3]
						else
							found_owner = nil
						end

						if found_owner =~ /Прочие/
							found_owner = nil
						end
						if !found_owner.nil?
							owner_name_rus = found_owner.strip
							owner_name = translit(found_owner.strip)
							puts "----------- Current vessel owner name +#{v.owner.name unless v.owner.nil?}+ -------------"
							puts "----------- The vessel belongs to +#{owner_name}+ -------------"
						else
							owner_name_rus = nil
							owner_name = nil
							puts "------------ The vessel's owner is UNKNOWN ---------------"
						end

						found_operator_full = agent.page.search('.s1 td:contains("Оператор:")')[0] || agent.page.search('.s11 td:contains("Оператор:")')[0]
						if !found_operator_full.nil?
							found_operator = found_operator_full.parent.children[1].text

							if found_operator =~ /Прочие|Проч/
								found_operator = nil
							end
							if !found_operator.nil?
								operator_name_rus = found_operator.strip
								operator_name = translit(found_operator)
								puts "----------- #{operator_name} (#{operator_name_rus}) -------------"
							else
								operator_name_rus = nil
								operator_name = nil
								puts "___________ The vessel has NO OPERATOR ______________"
							end
						else
							operator_name_rus = nil
							operator_name = nil
							puts "___________ The vessel has NO OPERATOR ______________"
						end

						found_notes_full = agent.page.search('.s1 td:contains("Примечание:")')[0] || agent.page.search('.s11 td:contains("Примечание:")')[0]

						if !found_notes_full.nil?
							found_notes = ((found_notes_full.text + " " + found_notes_full.parent.children[1].text).prepend("#{operator_name}" + "(" + "#{operator_name_rus}" + ")" + "; ")).strip
							puts "----------- Additional info #{found_notes} -------------"
						elsif found_notes_full.nil? && !operator_name.nil?
							found_notes = (operator_name + "(" + operator_name_rus + ")" + ";").strip
							puts "----------- Additional info #{found_notes} -------------"
						else
							found_notes = nil
							puts "___________ No extra notes found. ___________"
						end
					
						found_date_full = agent.page.search('.s1 td:contains("Построено:")')[0] || agent.page.search('.s11 td:contains("Построено:")')[0]

						if !found_date_full.nil?
							found_date = found_date_full.parent.children[1].text
							puts "----------- Built on #{found_date} -------------"
							puts " "
						else
							found_owner = nil
							puts "----------- There is no DATE indicated -------------"
							puts " "
						end
						if !found_date.nil? && v.blt_year.nil?
							if found_date.length == 7
								built = Date.parse(found_date.prepend("01."))
								puts ">>>>>>>>>>> DATE <<<<<<<<<<<<<<"
								puts "The vessel was build #{built}"
							elsif found_date.length == 4
								built = Date.parse(found_date.prepend("01.01."))
								puts ">>>>>>>>>>> DATE <<<<<<<<<<<<<<"
								puts "The vessel was build #{built}"
							elsif found_date.length == 10
								built = Date.parse(found_date)
								puts ">>>>>>>>>>> DATE <<<<<<<<<<<<<<"
								puts "The vessel was build #{built}"
							else
								built = nil
								puts " "
								puts ">>>>>>>>>>> DATE IS UNKNOWN <<<<<<<<<<<<<<"
								puts " "
							end
							v.update_attributes(:blt_year => built)
							v.save!
						end
					rescue Mechanize::ResponseCodeError => ex
						puts ex.response_code
						if ex.response_code == '404'
							puts "The vessel has different MMSI or IMO number on different sites"
						else
							#raise ex
							puts ex.response_code
						end
					end
				else
					puts "<<<<<<<<<<<<<<<<<<< ALARM >>>>>>>>>>>>>>>>>>>"
					puts "Fleetphoto page has NO CONTENT."
					next
				end
				puts "#{v.owner.nil?} and #{owner_name.nil?} and #{found_notes.nil?}"
				if v.owner.nil? && !owner_name.nil?
					o = Owner.find_by_name(owner_name)
					o ||= Owner.create(:name => owner_name, :rus_name => owner_name_rus, :notes => found_notes)
					o.save!
					v.update_attributes(:owner_id => o.id)
					v.save!
					puts "Created new owner company #{owner_name} (#{owner_name_rus}) with additional notes #{found_notes}"
				elsif v.owner.nil? && !found_notes.nil?
					o = Owner.find_by_name(owner_name)
					o ||= Owner.create(:name => owner_name, :rus_name => owner_name_rus, :notes => found_notes)
					o.save!
					v.update_attributes(:owner_id => o.id)
					v.save!
					puts "Created new owner company #{owner_name} (#{owner_name_rus}) with additional notes #{found_notes}"
				elsif v.owner.nil? && owner_name.nil? && found_notes.nil?
					puts "The owner or operator is UKNOWN. There is no additional info either."
				elsif v.owner.name != owner_name
					o = Owner.find_by_name(owner_name)
					o ||= Owner.create(:name => owner_name, :rus_name => owner_name_rus, :notes => found_notes)
					o.save!
					v.update_attributes(:owner_id => o.id)
					v.save!
					puts "Updated owner company #{owner_name} (#{owner_name_rus}) for vessel #{v.id} #{v.vsl_name}"
					puts ''
					puts "++++++++++++++ COMPLETED ++++++++++++++"
				elsif v.owner.name == owner_name
					puts "The vessel's owner is still the same"
					puts "++++++++++++ NEXT VESSEL ++++++++++++++"
					puts " "
				elsif v.owner.name =~ /Prochie|Proch/
					v.update_attributes(:owner_id => nil)
					v.save!
					puts "The vessel's owner is not known, but please check the ADITIONAL INFO"
					puts "++++++++++++ NEXT VESSEL ++++++++++++++"
					puts " "
				else
					puts '!!!!!!!!!!!!!---------------!!!!!!!!!!!!!!!!!!'
					puts "Something went wrong with owner #{owner_name} (#{owner_name_rus}) and the vessel #{v.id} #{v.vsl_name}"
					puts '!!!!!!!!!!!!!---------------!!!!!!!!!!!!!!!!!!'
					next
				end
			else
				puts " "
				puts ">>>>>>>>>>>>>>>>>>> IMO is NULL <<<<<<<<<<<<<<<<<<<<<"
				next
			end
		end    	
    else
       	puts "The IMO number was provided. So all we need is a single vessel."
		imo = args.imo

		v = Vessel.find_by_imo(imo)

		puts "We will be looking for the OWNER of vessel #{v.vsl_name}."

		url = "http://fleetphoto.ru/ajax2.php?action=index-qsearch&num=&exact=0&imo=" + imo + "&mmsi="
			
		puts url
		
		page = open(url,'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.874.121 Safari/535.2').read
		puts "Loaded first page..."
		sleep rand(3..9)
		if page.length > 2
			puts "Page has content"
			fleet_ref = page[9..13].gsub("\"","").gsub(",","")
			puts "The reference number is #{fleet_ref}"
			url = "http://fleetphoto.ru/ship/" + fleet_ref + "/"
			puts "Opening #{url}"
			begin
				agent.get(url)
				puts "Page loaded. Searching for the owner's name"

				found_owner_full = agent.page.search('.s1 td:contains("Владелец")')[0] || agent.page.search('.s11 td:contains("Владелец:")')[0]

				if !found_owner_full.nil?
					found_owner = found_owner_full.parent.children[1].text[0..-3]
				else
					found_owner = nil
				end

				if found_owner =~ /Прочие|Проч/
					found_owner = nil
				end
				if !found_owner.nil?
					owner_name_rus = found_owner.strip
					owner_name = translit(found_owner.strip)
					puts "----------- The vessel belongs to +#{owner_name}+, #{owner_name_rus} -------------"
				else
					owner_name_rus = nil
					owner_name = nil
					puts "The vessel's owner is unknown."
				end

				found_operator_full = agent.page.search('.s1 td:contains("Оператор:")')[0] || agent.page.search('.s11 td:contains("Оператор:")')[0]

				if !found_operator_full.nil?
					found_operator = found_operator_full.parent.children[1].text

					if found_operator =~ /Прочие/
						found_operator = nil
					end
					if !found_operator.nil?
						operator_name_rus = found_operator.strip
						operator_name = translit(found_operator.strip)
						puts "----------- Operator is #{operator_name} (#{operator_name_rus}) -------------"
					else
						operator_name_rus = nil
						operator_name = nil
						puts "___________ The vessel has NO OPERATOR ______________"
					end
				else
					operator_name_rus = nil
					operator_name = nil
					puts "___________ The vessel has NO OPERATOR ______________"
				end

				found_notes_full = agent.page.search('.s1 td:contains("Примечание:")')[0] || agent.page.search('.s11 td:contains("Примечание:")')[0]

				if !found_notes_full.nil?
					found_notes = ((found_notes_full.text + " " + found_notes_full.parent.children[1].text).prepend("#{operator_name}" + "(" + "#{operator_name_rus}" + ")" + "; ")).strip
					puts "----------- Additional info #{found_notes} -------------"
				elsif found_notes_full.nil? && !operator_name.nil?
					found_notes = (operator_name + "(" + operator_name_rus + ")" + ";").strip
					puts "----------- Additional info #{found_notes} -------------"
				else
					found_notes = nil
					puts "___________ No extra notes found. ___________"
				end

				found_date_full = agent.page.search('.s1 td:contains("Построено:")')[0] || agent.page.search('.s11 td:contains("Построено:")')[0]

				if !found_date_full.nil?
					found_date = found_date_full.parent.children[1].text
					puts "----------- Built on #{found_date} -------------"
					puts " "
				else
					found_owner = nil
					puts "----------- There is no DATE indicated -------------"
					puts " "
				end

				if !found_date.nil? && v.blt_year.nil?
					if found_date.length == 7
						built = Date.parse(found_date.prepend("01."))
						puts ">>>>>>>>>>> DATE <<<<<<<<<<<<<<"
						puts "The vessel was build #{built}"
					elsif found_date.length == 4
						built = Date.parse(found_date.prepend("01.01."))
						puts ">>>>>>>>>>> DATE <<<<<<<<<<<<<<"
						puts "The vessel was build #{built}"
					elsif found_date.length == 10
						built = Date.parse(found_date)
						puts ">>>>>>>>>>> DATE <<<<<<<<<<<<<<"
						puts "The vessel was build #{built}"
					else
						built = nil
						puts " "
						puts ">>>>>>>>>>> DATE IS UNKNOWN <<<<<<<<<<<<<<"
						puts " "
					end
					v.update_attributes(:blt_year => built)
					v.save!
				end
			rescue Mechanize::ResponseCodeError => ex
				puts ex.response_code
				if ex.response_code == '404'
					puts "The vessel has different MMSI or IMO number on different sites"
				else
					#raise ex
					puts ex.response_code
				end
			end
		else
			puts "<<<<<<<<<<<<<<<<<<< ALARM >>>>>>>>>>>>>>>>>>>"
			puts "Fleetphoto page has NO CONTENT. Trying the alternative sources."

		end
		
		if v.owner.nil? && ( !owner_name.nil? || !found_notes.nil? )
			o = Owner.find_by_name(owner_name)
			o ||= Owner.create(:name => owner_name, :rus_name => owner_name_rus, :notes => found_notes)
			o.save!
			v.update_attributes(:owner_id => o.id)
			v.save!
			puts "Created new owner company #{owner_name} (#{owner_name}) for vessel #{v.id} #{v.vsl_name}"
		elsif v.owner.nil? && !found_notes.nil?
			o = Owner.find_by_name(owner_name)
			o ||= Owner.create(:name => owner_name, :rus_name => owner_name_rus, :notes => found_notes)
			o.save!
			v.update_attributes(:owner_id => o.id)
			v.save!
			puts "Created new owner company #{owner_name} (#{owner_name_rus}) with additional notes #{found_notes}"
		elsif v.owner.nil? && owner_name.nil? && found_notes.nil?
			puts "The owner or operator is UKNOWN. There is no additional info either."
		elsif v.owner.name == owner_name
			puts "The vessel's owner is still the same"
			puts "++++++++++++ All done ++++++++++++++"
		elsif v.owner.name != owner_name
			o = Owner.find_by_name(owner_name)
			o ||= Owner.create(:name => owner_name, :rus_name => owner_name_rus, :notes => found_notes)
			v.update_attributes(:owner_id => o.id)
			v.save!
			puts "Updated owner company #{owner_name} (#{owner_name}) with additional notes #{found_notes}"
			puts ''
			puts "++++++++++++++ COMPLETED ++++++++++++++"
		elsif v.owner.name =~ /Prochie|Proch/
			v.update_attributes(:owner_id => nil)
			v.save!
			puts "The vessel's owner is not known, but please check the ADITIONAL INFO"
			puts "++++++++++++ NEXT VESSEL ++++++++++++++"
			puts " "
		else
			puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
			puts "+#{v.owner.name}+"
			puts "Nothing to update for +#{owner_name}+ (#{owner_name_rus}) and the vessel #{v.id}. #{v.vsl_name}"
			puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
			next
		end
	end
end
end