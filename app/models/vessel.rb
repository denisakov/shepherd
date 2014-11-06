class Vessel < ActiveRecord::Base
	validates_presence_of :vsl_name, :vsl_type#, :vsl_flag, :blt_year

	# validates_uniqueness_of :imo
	# validates :imo, :imo_format => true

	has_many :positions
	has_many :shipments, :dependent => :destroy

	belongs_to :owner
	#select('vessels.*, COUNT(shipments.id) AS shipments_count')
	#scope :russian_vessels, -> { where("vsl_flag = ? or vsl_flag = ?", "Russia", "")}
	scope :engaged_vessels, -> { joins(:shipments => [:shipment_statuses]).where('shipment_statuses.created_at = (SELECT MAX(shipment_statuses.created_at) FROM shipment_statuses WHERE shipment_statuses.shipment_id = shipments.id)')}
	scope :free_vessels, -> { all }#joins(:shipments).where('shipment_id = ?', nil)}.joins(:shipments => [:shipment_statuses]).where.not('shipment_statuses.status IN (?)', ["Completed", nil])}
	scope :active_vessels, -> { engaged_vessels.where.not("status = ?","Completed")}
	scope :done_vessels, -> { engaged_vessels.where("status = ?","Completed")}
end