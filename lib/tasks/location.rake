namespace :crawl do
  desc "collects and updates data from more external sources external sources"
  task :location, [:vessel_imos] => :environment do |t, args|
    require 'rubygems'
    require 'open-uri'
    require 'roo'
   	require 'mechanize'

   	puts "________________________________"
    puts "Starting to look for NEW LOCATION"
    puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

	agent = Mechanize.new

	if args.count == 0

		vmmsi = Array.new
		Vessel.all.each do |v|
			vmmsi << v.mmsi
		end

		puts "Uploaded files. Ready to start analyses"

		vmmsi.each_with_index do |a, index|

			n = rand(0..14)
	
			m = [{0=>'Linux Firefox'},{1=>'Linux Konqueror'},{2=>'Linux Mozilla'},{3=>'Mac Firefox'},{4=>'Mac Mozilla'},{5=>'Mac Safari 4'},{6=>'Mac Safari'},{7=>'Windows Chrome'},{8=>'Windows IE 6'},{9=>'Windows IE 7'},{10=>'Windows IE 8'},{11=>'Windows IE 9'},{12=>'Windows Mozilla'},{13=>'iPhone'},{14=>'iPad'}]

			agent.cookie_jar.clear!

			agent.user_agent_alias = m[n][n]

			puts "Assigned the AGENT - #{m[n][n]}"

			if index % 40 == 0
				sleep rand(5..20)
			end

			pos = Array.new
			mmsi = a
			if mmsi.nil?
				next
			end
			url = "http://www.marinetraffic.com/en/ais/details/ships/" + mmsi
			sleep rand(1..9)
			puts url

			begin
				agent.get(url)
				puts "Loaded page for vessel #{mmsi}"

				# last_upt = agent.page.search("/html/body/div/div[3]/div[1]/div[2]/div[2]/div[1]/div[1]/span[2]/strong/span").children[0].text
				if !agent.page.search('span:contains("Info Received:")').empty? then
					last_upt = Date.parse(agent.page.search('span:contains("Info Received:")')[0].parent.children[3].text)
				else
					v = Vessel.find_by_mmsi(mmsi)
					imo = v.imo
					url = "http://www.vesselfinder.com/en-us/vessels/IMO-" + imo + "-MMSI-" + mmsi
					agent.get(url)
					sleep rand(2..6)
					if agent.page.search('span:contains("Last report:")')[0].parent.children[5] =~ /\d/
						last_upt = Date.parse(agent.page.search('span:contains("Last report:")')[0].parent.children[5].text)
					else
						last_upt = ""
					end
				end
				puts "Last update #{last_upt}"

				# general status of the vessel
				# agent.page.search('span:contains("Status")')[0].parent.children[3].text
				nav_status = "Unknown"
				nav_status = agent.page.search('span:contains("Status")')[1].parent.children[3].text unless agent.page.search('span:contains("Status")')[1].nil?

				puts "Current status is: #{nav_status}"

				#Just in case we would need to find the area later on
				#area = agent.page.search("/html/body/div/div[3]/div[1]/div[2]/div[2]/div[1]/div[2]").children[3].text

				if !agent.page.parser.css(".voyage-related").search("tr").empty?

					dest = agent.page.parser.css(".voyage-related").search("tr").children
					
					dest.each do |d|
						if !d.text.strip.blank?
							pos << d.text.strip
						else
							next
						end
					end

					a = Array.new
					b = Array.new

					a = pos.values_at(* pos.each_index.select {|i| i.even?})
					b = pos.values_at(* pos.each_index.select {|i| i.odd?})

					pos = []

					for i in 0..a.length-1
						pos << [a[i],b[i]]
					end

					dest = ""
					last_port = ""
					prev_dest = ""
					eta = ""

					pos.each do |a|
						if a[0] =~ /Destination/
							if a[1] =~ /\[/
								dest = a[1][0..a[1].index("[")-2]
							elsif a[1] =~ /\(/
								dest = a[1][0..a[1].index("(")-2]
							elsif
								dest = a[1]
							end
						end
						if a[0] =~ /Known/
							if a[1] =~ /\[/
								last_port = a[1][0..a[1].index("[")-2]
							elsif a[1] =~ /\(/
								last_port = a[1][0..a[1].index("(")-2]
							elsif
								last_port = a[1]
							end
						end
						if a[0] =~ /Previous/
							if a[1] =~ /\[/
								prev_dest = a[1][0..a[1].index("[")-2]
							elsif a[1] =~ /\(/
								prev_port = a[1][0..a[1].index("(")-2]
							elsif
								prev_dest = a[1]
							end
						end
						if a[0] =~ /Info/
							last_upt = Date.parse(a[1][0..a[1].index("(")-2])
						end
						if a[0] =~ /ETA/
							eta = Date.parse(a[1])
						end
					end

					lat = ""
					long = ""

					v = Vessel.find_by_mmsi(mmsi)
					if v.positions.empty?
						v.positions.build(:long => long, :lat => lat, :dest => dest, :prev_dest => prev_dest, :last_port => last_port, :eta => eta, :nav_status => nav_status, :last_upt => last_upt)
						v.save!
						puts "Inserted new directions as there was previously none"
					elsif !v.positions.last.last_upt.nil? && v.positions.last.last_upt < last_upt
						v.positions.build(:dest => dest, :prev_dest => prev_dest, :last_port => last_port, :eta => eta, :nav_status => nav_status, :last_upt => last_upt)
						v.save!
						puts "Inserted new directions, because there was new info"
					elsif v.positions.last.dest.nil?
						v.positions.last.update_attributes(:dest => dest, :last_port => last_port, :eta => eta, :nav_status => nav_status, :last_upt => last_upt)
						v.save!
						puts "Inserted new directions, because there was new info on current heading: #{dest}"
					elsif v.positions.last.prev_dest.nil?
						v.positions.last.update_attributes(:prev_dest => prev_dest, :last_port => last_port, :eta => eta, :nav_status => nav_status, :last_upt => last_upt)
						v.save!
						puts "Inserted new directions, because there was new info on previous destination: #{prev_dest}"
					elsif
						puts "Skipping vessel!"
						puts " "
						next
					end

					puts "++++++++++++"
					puts "Voyage info:"
					puts "Form port #{prev_dest} to port #{dest}"
					puts "ETA #{eta}"
					puts "Info was received #{last_upt}"
					puts "++++++++++++"
				else
					puts "There was no info at the website"
					puts " "
					next
				end

			rescue Mechanize::ResponseCodeError => ex
				puts ex.response_code
			end
		end
	else
		puts "#{args.vessel_imos} IMO number was provided. We will find the vessel now."

    	args.vessel_imos.each do |imo|
			pos = Array.new
			
			url = "http://www.marinetraffic.com/en/ais/details/ships/" + imo
			puts "Started looking at a single vessel at #{url}"

			begin
				agent.get(url)
				puts "Loaded page for vessel #{imo}"

				# last_upt = agent.page.search("/html/body/div/div[3]/div[1]/div[2]/div[2]/div[1]/div[1]/span[2]/strong/span").children[0].text
				if !agent.page.search('span:contains("Info Received:")').empty? then
					last_upt = Date.parse(agent.page.search('span:contains("Info Received:")')[0].parent.children[3].text)
				else
					last_upt = ""
				end
				puts "Last update was on #{last_upt}"

				# general status of the vessel
				# agent.page.search('span:contains("Status")')[0].parent.children[3].text
				nav_status = "Unknown"
				nav_status = agent.page.search('span:contains("Status")')[1].parent.children[3].text unless agent.page.search('span:contains("Status")')[1].nil?

				puts "Current status is: #{nav_status}"

				#Just in case we would need to find the area later on
				#area = agent.page.search("/html/body/div/div[3]/div[1]/div[2]/div[2]/div[1]/div[2]").children[3].text

				if !agent.page.parser.css(".voyage-related").search("tr").empty?

					dest = agent.page.parser.css(".voyage-related").search("tr").children
					
					dest.each do |d|
						if !d.text.strip.blank?
							pos << d.text.strip
						else
							next
						end
					end

					a = Array.new
					b = Array.new

					a = pos.values_at(* pos.each_index.select {|i| i.even?})
					b = pos.values_at(* pos.each_index.select {|i| i.odd?})

					pos = []

					for i in 0..a.length-1
						pos << [a[i],b[i]]
					end

					dest = ""
					last_port = ""
					prev_dest = ""
					eta = ""

					pos.each do |a|
						if a[0] =~ /Destination/
							if a[1] =~ /\[/
								dest = a[1][0..a[1].index("[")-2]
							elsif a[1] =~ /\(/
								dest = a[1][0..a[1].index("(")-2]
							elsif
								dest = a[1]
							end
						end
						if a[0] =~ /Known/
							if a[1] =~ /\[/
								last_port = a[1][0..a[1].index("[")-2]
							elsif a[1] =~ /\(/
								last_port = a[1][0..a[1].index("(")-2]
							elsif
								last_port = a[1]
							end
						end
						if a[0] =~ /Previous/
							if a[1] =~ /\[/
								prev_dest = a[1][0..a[1].index("[")-2]
							elsif a[1] =~ /\(/
								prev_port = a[1][0..a[1].index("(")-2]
							elsif
								prev_dest = a[1]
							end
						end
						if a[0] =~ /Info/
							last_upt = Date.parse(a[1][0..a[1].index("(")-2])
						end
						if a[0] =~ /ETA/
							eta = Date.parse(a[1])
						end
					end

					lat = ""
					long = ""

					v = Vessel.find_by_imo(imo)
					if v.positions.empty?
						v.positions.build(:long => long, :lat => lat, :dest => dest, :prev_dest => prev_dest, :last_port => last_port, :eta => eta, :nav_status => nav_status, :last_upt => last_upt)
						v.save!
						puts "Inserted new directions as there was previously none"
					elsif v.positions.last.last_upt < last_upt
						v.positions.build(:dest => dest, :prev_dest => prev_dest, :last_port => last_port, :eta => eta, :nav_status => nav_status, :last_upt => last_upt)
						v.save!
						puts "Inserted new directions, because there was new info"
					elsif v.positions.last.dest.nil?
						v.positions.last.update_attributes(:dest => dest, :last_port => last_port, :eta => eta, :nav_status => nav_status, :last_upt => last_upt)
						v.save!
						puts "Inserted new directions, because there was new info on current heading: #{dest}"
					elsif v.positions.last.prev_dest.nil?
						v.positions.last.update_attributes(:prev_dest => prev_dest, :last_port => last_port, :eta => eta, :nav_status => nav_status, :last_upt => last_upt)
						v.save!
						puts "Inserted new directions, because there was new info on previous destination: #{prev_dest}"
					elsif v.positions.last.updated_at < Time.now
						v.positions.build(:dest => dest, :prev_dest => prev_dest, :last_port => last_port, :eta => eta, :nav_status => nav_status, :last_upt => last_upt)
						v.save!
						puts "Inserted new directions, because the user requested so"
					elsif
						puts "Skipping vessel, as there is nothing to update"
					end
					puts ''
					puts "Voyage info:"
					puts "Form port #{prev_dest} to port #{dest}"
					puts "ETA #{eta}"
					puts "Info was received on #{last_upt}"
				else
					puts "There was no info at the website"
					next
				end
				sleep rand(2..6)
			rescue Mechanize::ResponseCodeError => ex
				puts ex.response_code
			end
		end
	end
  end
end