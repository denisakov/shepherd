class Owner < ActiveRecord::Base
	#validates_presence_of :name, :rus_name

	has_many :vessels
end
