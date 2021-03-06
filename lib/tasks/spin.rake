namespace :crawl do
	desc "collects and updates data from external sources"
    
    task :new, [:vessel_imos] => :environment do |t, args|
        puts args.count
        puts args.inspect
        #puts args[:vessel_imos].split(" ").map(&:to_i)
        vessel_imos = Array.new
        
        #puts "#{vessel_imos}"
        
        if args.count == 0 
            puts "we'll scan it all"
            Rake::Task['crawl:vessel'].invoke
            Rake::Task['crawl:vessel'].reenable
            Rake::Task['crawl:owner'].invoke
            Rake::Task['crawl:owner'].reenable
            Rake::Task['crawl:location'].invoke
            Rake::Task['crawl:location'].reenable
            Rake::Task['crawl:gps'].invoke
            Rake::Task['crawl:gps'].reenable
            Rake::Task['crawl:vessel_type'].invoke
            Rake::Task['crawl:vessel_type'].reenable

        else
            # if args.vessel_imos.count !=~ /^[0-9]{7}*$/
            #    puts "there must 7 digits only"
            #    next
            # else
                args[:vessel_imos].split(", ").each do |i|
                    vessel_imos << i
                end
                
                puts "#{vessel_imos}"

                Rake::Task['crawl:vessel'].invoke(vessel_imos)
                Rake::Task['crawl:vessel'].reenable
                Rake::Task['crawl:owner'].invoke(vessel_imos)
                Rake::Task['crawl:owner'].reenable
                Rake::Task['crawl:location'].invoke(vessel_imos)
                Rake::Task['crawl:location'].reenable
                Rake::Task['crawl:gps'].invoke(vessel_imos)
                Rake::Task['crawl:gps'].reenable
                
                #Rake::Task['crawl:vessel_type'].invoke(imo)
            # end
        end
        
    end

end