class ShipmentStatus < ActiveRecord::Base
	validates_presence_of :shipment_id, :status

	belongs_to :shipment
end
