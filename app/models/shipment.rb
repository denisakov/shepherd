class Shipment < ActiveRecord::Base
	validates_presence_of :title, :vessel_id
	
	belongs_to :vessel
	has_many :shipment_statuses, :dependent => :destroy
	accepts_nested_attributes_for :shipment_statuses

	scope :engaged, -> { includes(:shipment_statuses).where('shipment_statuses.created_at = (SELECT MAX(shipment_statuses.created_at) FROM shipment_statuses WHERE shipment_statuses.shipment_id = shipments.id)')}
	scope :active, -> { engaged.where.not("shipment_statuses.status = ?", "Completed").references(:shipment_statuses)}
	scope :done, -> { engaged.where("shipment_statuses.status = ?", "Completed").references(:shipment_statuses)}
end
