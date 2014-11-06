namespace :crawl do
  desc "collects and updates data from more external sources external sources"
  task :vessel_2 => :environment do
    require 'rubygems'
    require 'open-uri'
    require 'roo'
	# require 'nokogiri'
   	require 'mechanize'
 #   require 'timeout'

	agent = Mechanize.new

	vimo = Array.new
	Vessel.all.each do |v|
		vimo << v.imo
	end

	ref = Roo::Spreadsheet.open("./lib/assets/Ref.xlsx")

	r = Array.new

	ref.each do |y|
		r << [y[0].to_int.to_s,y[1]]
	end

	x = Roo::Spreadsheet.open("./lib/assets/imos.xlsx")

	puts "Uploaded files ready to start"

	x.each do |a|

		if !vimo.include? a[0].to_int.to_s
			imo = a[0].to_int.to_s
			url = "http://fleetphoto.ru/ajax2.php?action=index-qsearch&num=&exact=0&imo=" + a[0].to_int.to_s + "&mmsi="

			puts url
			
			page = open(url,'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.874.121 Safari/535.2').read
			puts "Loaded first page..."
			if page.length > 2
				puts "Page has content"
				fleet_ref = page[9..13].gsub("\"","")
				puts fleet_ref
				url = "http://fleetphoto.ru/ship/" + fleet_ref + "/"
				puts "Opening #{url}"
				page = open(url,'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.874.121 Safari/535.2').read
				page.encode!("utf-8", "utf-8")
				puts "Page loaded. Searching for data"
				if !(page =~ /[\d]{9}/).nil?
					mmsi = page[(page =~ /[\d]{9}/)..(page =~ /[\d]{9}/)+8]

					puts "MMSI #{mmsi}"

					url = "http://www.marinetraffic.com/ru/ais/details/ships/" + mmsi

					sleep 1

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
					rescue Mechanize::ResponseCodeError => ex
						puts ex.response_code
					end
				else
					"The vessel is most probably sank or broken."
					next
				end
				
			else
				puts "Page has no content"
				sleep 2
				next
			end
		else
			puts "Vessel already exists"
			next
		end
	end

end
end
