class Vessel < ActiveRecord::Base
	validates_presence_of :vsl_name, :vsl_type#, :vsl_flag, :blt_year

	# validates_uniqueness_of :imo
	# validates :imo, :imo_format => true

	has_many :positions
	has_many :shipments, :dependent => :destroy

	belongs_to :owner
	#select('vessels.*, COUNT(shipments.id) AS shipments_count')
	#scope :russian_vessels, -> { where("vsl_flag = ? or vsl_flag = ?", "Russia", "")}
	# 	scope :free_vessels, -> { where(never_engaged.ast.cores.last.wheres.last.or(done_vessels.ast.cores.last.wheres.inject{|ws, w| (ws &&= ws.and(w)) || w}))}
	scope :never_engaged, -> { where.not(id: Shipment.select(:vessel_id)) }
	scope :engaged_vessels, -> { includes(:positions).joins(:shipments => [:shipment_statuses]).where('shipment_statuses.created_at = (SELECT MAX(shipment_statuses.created_at) FROM shipment_statuses WHERE shipment_statuses.shipment_id = shipments.id)')}
	scope :free_vessels, -> { all }
	scope :active_vessels, -> { engaged_vessels.where.not("status = ?","Completed")}
	scope :done_vessels, -> { engaged_vessels.where("status = ?","Completed")}
end