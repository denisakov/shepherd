namespace :crawl do
  desc "collects and updates data from external sources"
  task :vessel, [:vessel_imos] => :environment do |t, args|
    require 'rubygems'
    require 'open-uri'
    require 'roo'
    require 'mechanize'
    require 'open3'
    require 'time'

	def creation_time(file)
		Time.parse(Open3.popen3("mdls","-name","kMDItemContentCreationDate","-raw", file)[1].read) 
	end

    puts "________________________________"
    puts "Starting to look for NEW vessels"
    puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

    agent = Mechanize.new
	agent.user_agent_alias = 'Windows Mozilla'

	vimo = Array.new
	Vessel.all.each do |v|
		vimo << v.imo
	end

	ref = Roo::Spreadsheet.open("./lib/assets/Ref.xlsx")

	r = Array.new

	ref.each do |y|
		r << [y[0].to_int.to_s,y[1]]
	end

	puts "Loaded the reference. Proceeding with IMO search."

    if args.count == 0
    	puts ''
    	puts "Seems like the IMO number wasn't passed, so we will go trough the C.xlsx"
    	puts ''

    	if Date.parse(creation_time("./lib/assets/C.xlsx").to_s) == Date.today

			x = Roo::Spreadsheet.open("./lib/assets/C.xlsx")

			x.drop(1).each do |a|
				eta = a[10]
				puts "ETA #{eta}"
				dest = a[9]
				puts "Destin #{dest}"
				prev_dest = a[11]
				puts "Prev_Destin #{prev_dest}"
				last_port = a[13]
				puts "Last port #{last_port}"
				nav_status = a[14]
				puts "Status #{nav_status}"
				# last_upt = a[20]
				# puts "Last update #{last_upt}"
				lat = a[21]
				puts "Latitude #{lat}"
				long = a[22]
				puts "Longitude #{long}"				

				if !a[2].nil? and !vimo.include? a[2].to_int.to_s
					imo = a[2].to_int.to_s
					mmsi = a[1].to_int.to_s
					vsl_name = a[0]
					flag = a[3]
					r.each do |y|
						if y[0]==imo then
							@vsl_type = y[1]
							break
						else
							@vsl_type = "Unknown"
						end
					end
					v = Vessel.create(:vsl_name => vsl_name, :imo => imo, :mmsi => mmsi, :vsl_flag => flag, :vsl_type => @vsl_type)
					v.save!
					puts "Created vessel #{v.id} #{vsl_name}"
					v.positions.build(:long => long, :lat => lat, :dest => dest, :prev_dest => prev_dest, :last_port => last_port, :eta => eta, :nav_status => nav_status)
					v.save!
					puts "Created new position for vessel #{v.id} #{vsl_name}"
				else
					if !a[2].nil?
						imo = a[2].to_int.to_s
						v = Vessel.find_by_imo(imo)
						puts "Found vessel #{v.id} #{v.vsl_name}"
						v.positions.build(:long => long, :lat => lat, :dest => dest, :prev_dest => prev_dest, :last_port => last_port, :eta => eta, :nav_status => nav_status)
						v.save!
						puts "Created new position for old vessel #{v.id} #{v.vsl_name}"
						puts ''
						puts "NEXT"
					end
				end
			end
		else
			puts " "
			puts ">>>>>>>>>>>>> The EXCEL file is too old, get a new one <<<<<<<<<<<<<<<"
			next
		end  	
    else
    	puts " "
    	puts "IMO numbers were provided. We will find the vessel now."
    	puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    	puts " "

    	args.vessel_imos.each do |imo|
			if !vimo.include? imo
				url = "http://fleetphoto.ru/ajax2.php?action=index-qsearch&num=&exact=0&imo=" + imo + "&mmsi="

				puts url
				
				page = open(url,'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.874.121 Safari/535.2').read
				puts "Loaded first page..."
				if page.length > 2
					puts "Page has content"
					fleet_ref = page[9..13].gsub("\"","").gsub(",","")
					puts fleet_ref
					url = "http://fleetphoto.ru/ship/" + fleet_ref + "/"
					puts "Opening #{url}"

					
					page = open(url,'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.874.121 Safari/535.2').read
					

					page.encode!("utf-8", "utf-8")
					puts "Page loaded. Searching for data"
					if !(page =~ /[\d]{9}/).nil?
						mmsi = page[(page =~ /[\d]{9}/)..(page =~ /[\d]{9}/)+8]

						#puts "MMSI #{mmsi}"

						url = "http://www.marinetraffic.com/ru/ais/details/ships/" + imo
						puts url

						begin
							agent.get(url)

							str = agent.page.at("title").children[0].text
							@vsl_name = str[0..str.index(" - ")-1]
							@flag = str[(str =~ /Registered in/)+13..(str =~ /- AIS Marine/)-1].strip
							r.each do |y|
								if y[0]==imo then
									@vsl_type = y[1]
									break
								else
									@vsl_type = "Unknown"
								end
							end
							v = Vessel.create(:vsl_name => @vsl_name, :imo => imo, :mmsi => mmsi, :vsl_flag => @flag, :vsl_type => @vsl_type)
							v.save!
							puts "Created vessel #{v.id} #{@vsl_name}"
							sleep rand(2..6)
						rescue Mechanize::ResponseCodeError => ex
							puts ex.response_code
							if ex.response_code == '404'
								puts "The vessel has different MMSI or IMO number on different sites"
								next
							else
								#raise ex
								puts ex.response_code
								next
							end
						end
					else
						"The vessel is most probably sank or broken."
					end
					
				else
					puts "Fleetphoto page has NO CONTENT. Trying the alternative sources."

					url = "http://www.marinetraffic.com/ru/ais/details/ships/" + imo

						begin
							agent.get(url)
							str = agent.page.at("title").children[0].text
							@vsl_name = str[0..str.index(" - ")-1]
							@flag = str[(str =~ /Registered in/)+13..(str =~ /- AIS Marine/)-1].strip
							@mmsi = str[(str =~ /MMSI /)+5..(str =~ /, Callsign/)-1].strip
							r.each do |y|
								if y[0]==imo then
									@vsl_type = y[1]
									break
								else
									@vsl_type = "Unknown"
								end
							end
							v = Vessel.create(:vsl_name => @vsl_name, :imo => imo, :mmsi => @mmsi, :vsl_flag => @flag, :vsl_type => @vsl_type)
							v.save!
							puts "Created vessel #{v.id} #{@vsl_name}"
						rescue Mechanize::ResponseCodeError => ex
							puts ex.response_code
							if ex.response_code == '404'
								puts "The vessel has different MMSI or IMO number on different sites"
							else
								#raise ex
								puts ex.response_code
							end
						end
				end
			else
				puts " "
				puts "Vessel already exists"
				puts "^^^^^^^^^^^^^^^^^^^^^"
				puts " "
			end
		end
	end

end
end