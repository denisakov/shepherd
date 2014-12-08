namespace :crawl do
  desc "collects and updates data from more external sources external sources"
  task :gps, [:vessel_imos] => :environment do |t, args|
    require 'rubygems'
    require 'open-uri'
    require 'roo'
   	require 'mechanize'

   	puts "_____________________________________"
    puts "Starting to look for GPS COORDINATES"
    puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

	agent = Mechanize.new
	agent.user_agent_alias = 'Windows Chrome'

	vmmsi = Array.new
	Vessel.eager_load(:positions).where('positions.last_upt < ?', Date.today).each do |v|
		vmmsi << v.mmsi
	end

 	if args.count == 0
    	
    	puts "Seems like the IMO number wasn't passed"
    	puts ''
    	puts "Uploaded files. Ready to start analyses on #{vmmsi.length} vessels"
		vmmsi.each do |a|
			unless a.nil?

				pos = Array.new
				mmsi = a 
				url = "http://www.marinetraffic.com/en/ais/details/ships/" + mmsi
				sleep rand(4..10)
				puts url

				begin
					agent.get(url)
					puts "Loaded page for vessel #{mmsi}"
					lat = ""
					long = ""

					nav_status = "Unknown"
					nav_status = agent.page.search('span:contains("Status")')[1].parent.children[3].text unless agent.page.search('span:contains("Status")')[1].nil?

					unless agent.page.parser.css(".details_data_link").empty?
						gps = agent.page.parser.css(".details_data_link")[0].text
						puts "There is no problem with the MMSI number for this vessel"
						unless gps.split(%r{/\s*})[1].nil?
							lat = gps.split(%r{/\s*})[0][0..7]
							long = gps.split(%r{/\s*})[1][0..7]
						end
					else
						puts "Loading page with IMO"
						v = Vessel.find_by_mmsi(mmsi)
						imo = v.imo
						url = "http://www.marinetraffic.com/en/ais/details/ships/" + imo
						agent.get(url)
						unless agent.page.parser.css(".details_data_link").empty?
							gps = agent.page.parser.css(".details_data_link")[0].text
							unless gps.split(%r{/\s*})[1].nil?
								lat = gps.split(%r{/\s*})[0][0..7]
								long = gps.split(%r{/\s*})[1][0..7]
							end
						else
							puts " "
							puts "Will look at the VesselFinder now"
							url = "http://www.vesselfinder.com/en-us/vessels/IMO-" + imo + "-MMSI-" + mmsi
							puts url
							agent.get(url)
							sleep rand(2..6)
							lat = agent.page.search('span:contains("Lat/Lon:")')[0].parent.children[3].children[1].text
							puts lat
							if lat !=~ /N\/A/
								if lat[lat.index(" ")+1..-1] == "S"
									lat = "-" + lat[0..lat.index(" ")-1]
								else
									lat = lat[0..lat.index(" ")-1]
								end
								long = agent.page.search('span:contains("Lat/Lon:")')[0].parent.children[3].children[3].text
								if long[long.index(" ")+1..-1] == "W"
									long = "-" + long[0..long.index(" ")-1]
								else
									long = long[0..long.index(" ")-1]
								end
							else
								puts " "
								puts "There are no coordinates here either"
							end
							sleep rand(5..12)
						end
					end

					#puts "GPS - #{long}, #{lat}"

					if !agent.page.search('span:contains("Info Received:")').empty? then
						last_upt = Date.parse(agent.page.search('span:contains("Info Received:")')[0].parent.children[3].text)
					elsif agent.page.search('span:contains("Last report:")')[0].parent.children[5].text =~ /\d/
						last_upt = Date.parse(agent.page.search('span:contains("Last report:")')[0].parent.children[5].text)
					else
						last_upt = ""
					end
					
					v = Vessel.find_by_mmsi(mmsi)
					if v.positions.empty?
						v.positions.build(:long => long, :lat => lat, :last_upt => last_upt, :nav_status => nav_status)
						v.save!
						puts "Created a new position for the vessel."
						puts " "
					elsif v.positions.last.updated_at < Time.now
						v.positions.last.update_attributes(:long => long, :lat => lat, :last_upt => last_upt, :nav_status => nav_status)
						v.save!
						puts "Updated the last position for the vessel."
						puts " "
					elsif
						puts "Skipping vessel!"
						next
					end
					puts "++++++++++++"
					puts "Voyage info:"
					puts "Last update #{last_upt}"
					puts "Current location of the vessel is: Latitude #{lat}, Longitude #{long}"
					puts "Current status is: #{nav_status}"
					puts "+++++++++++++"
					puts " "

				rescue Mechanize::ResponseCodeError => ex
					puts ex.response_code
				rescue Errno::ETIMEDOUT
					retry
				end
			end
		end
	else
		puts "Checking coordinates for active vessels"
		
		all_vessels = args.vessel_imos[0]
		

		if args.vessel_imos[0].class == String
			puts "#{args.vessel_imos[0].class}"
			all_vessels = Array.new
			all_vessels << args.vessel_imos[0]
		end

    	all_vessels.each do |imo|
			puts imo.to_s
			pos = Array.new
			url = "http://www.marinetraffic.com/en/ais/details/ships/" + imo
			puts url

			begin
				v = Vessel.find_by_imo(imo)
				mmsi = v.mmsi
				agent.get(url)
				puts "Loaded page for vessel #{imo}"

				lat = ""
				long = ""

				unless agent.page.parser.css(".details_data_link").empty?
					gps = agent.page.parser.css(".details_data_link")[0].text
					unless gps.split(%r{/\s*})[1].nil?
						lat = gps.split(%r{/\s*})[0][0..7]
						long = gps.split(%r{/\s*})[1][0..7]
					end
				else
					puts " "
					puts "Will look at the VesselFinder now"
					url = "http://www.vesselfinder.com/en-us/vessels/IMO-" + imo + "-MMSI-" + mmsi
					puts url
					agent.get(url)
					sleep rand(2..6)
					lat = agent.page.search('span:contains("Lat/Lon:")')[0].parent.children[3].children[1].text
					if lat !=~ /N\/A/
						if lat[lat.index(" ")+1..-1] == "S"
							lat = "-" + lat[0..lat.index(" ")-1]
						else
							lat = lat[0..lat.index(" ")-1]
						end
						long = agent.page.search('span:contains("Lat/Lon:")')[0].parent.children[3].children[3].text
						if long[long.index(" ")+1..-1] == "W"
							long = "-" + long[0..long.index(" ")-1]
						else
							long = long[0..long.index(" ")-1]
						end
					else
						puts " "
						puts "There are no coordinate here either. Can't update the GPS."
						next
					end
					sleep rand(3..6)
				end
				
				#puts "GPS - #{long}, #{lat}"

				if !agent.page.search('span:contains("Info Received:")').empty? then
					last_upt = Date.parse(agent.page.search('span:contains("Info Received:")')[0].parent.children[3].text)
				elsif agent.page.search('span:contains("Last report:")')[0].parent.children[5].text =~ /\d/
					last_upt = Date.parse(agent.page.search('span:contains("Last report:")')[0].parent.children[5].text)
				else
					last_upt = ""
				end
				
				nav_status = "Unknown"
				nav_status = agent.page.search('span:contains("Status")')[1].parent.children[3].text unless agent.page.search('span:contains("Status")')[1].nil?

				if v.positions.empty?
					v.positions.build(:long => long, :lat => lat, :last_upt => last_upt, :nav_status => nav_status)
					v.save!
				elsif v.positions.last.updated_at < Time.now
					v.positions.last.update_attributes(:long => long, :lat => lat, :updated_at => DateTime.now, :last_upt => last_upt, :nav_status => nav_status)
					v.save!
				elsif
					puts "Skipping vessel, Because there is nothing to update"
				end
				puts "++++++++++++"
				puts "Voyage info:"
				puts "Last update #{last_upt}"
				puts "Current location of the vessel is: Latitude #{lat}, Longitude #{long}"
				puts "Current status is: #{nav_status}"
				puts "+++++++++++++"

			rescue Mechanize::ResponseCodeError => ex
				puts ex.response_code
			rescue Errno::ETIMEDOUT
				retry
			end
		end
	end
  end
end
