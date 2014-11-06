namespace :crawl do
	desc "collects and updates data from external sources"
    
    task :new, [:vessel_imos] => :environment do |t, args|
        puts args.count
        
        if args.count == 0 
            puts "we'll scan it all"
            Rake::Task['crawl:vessel'].invoke
            Rake::Task['crawl:location'].invoke
            Rake::Task['crawl:gps'].invoke
            Rake::Task['crawl:vessel_type'].invoke
            Rake::Task['crawl:owner'].invoke
        else
            # if args.vessel_imos.count !=~ /^[0-9]{7}*$/
            #    puts "there must 7 digits only"
            #    next
            # else
                vessel_imos = Array.new
                vessel_imos << args.vessel_imos
                puts vessel_imos
                
                Rake::Task['crawl:vessel'].invoke(vessel_imos)
                Rake::Task['crawl:location'].invoke(vessel_imos)
                Rake::Task['crawl:gps'].invoke(vessel_imos)
                Rake::Task['crawl:owner'].invoke(imo)
                #Rake::Task['crawl:vessel_type'].invoke(imo)
            # end
        end
        
    end

end