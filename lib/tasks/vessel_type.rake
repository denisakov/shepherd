namespace :crawl do
  desc "collects and updates data from more external sources external sources"
  task :vessel_type => :environment do
    require 'rubygems'
    require 'open-uri'
    require 'roo'
   	require 'mechanize'

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

	puts "Uploaded files ready to start"

	vimo.each do |a|
		imo = a
		v = Vessel.find_by_imo(imo)
		if v.vsl_type == "Unknown" || v.vsl_type.nil?
			r.each do |y|
				if y[0]==imo then
					@vsl_type = y[1]
					break
				else
					@vsl_type = "Unknown"
				end
			end
			v.update_attributes(:vsl_type => @vsl_type)
			v.save!
			puts "Updated type of vessel #{v.id} #{v.vsl_name}"
		else
			puts "Vessel type was defined previously!"
		end
	end
  end
end
