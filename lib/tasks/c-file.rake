namespace :crawl do
  desc "collects and updates data from external sources"
  task :vessel => :environment do
    require 'rubygems'
    require 'open-uri'
    require 'roo'
    require 'mechanize'

vimo = Array.new
Vessel.all.each do |v|
	vimo << v.imo
end

ref = Roo::Spreadsheet.open("./lib/assets/Ref.xlsx")

r = Array.new
ref.each do |y|
	r << [y[0].to_int.to_s,y[1]]
end

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
	last_upt = a[20]
	puts "Last update #{last_upt}"
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
		v.positions.build(:long => long, :lat => lat, :dest => dest, :prev_dest => prev_dest, :last_port => last_port, :eta => eta, :nav_status => nav_status, :last_upt => last_upt)
		v.save!
		puts "Created new position for vessel #{v.id} #{vsl_name}"
	else
		if !a[2].nil?
			imo = a[2].to_int.to_s
			v = Vessel.find_by_imo(imo)
			puts "Found vessel #{v.id} #{v.vsl_name}"
			v.positions.build(:long => long, :lat => lat, :dest => dest, :prev_dest => prev_dest, :last_port => last_port, :eta => eta, :nav_status => nav_status, :last_upt => last_upt)
			v.save!
			puts "Created new position for old vessel #{v.id} #{v.vsl_name}"
		end
	end
end

end
end
