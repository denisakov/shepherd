class Position < ActiveRecord::Base
	belongs_to :vessel

	#scope :latest, -> {order('last_upt DESC').first}
end
