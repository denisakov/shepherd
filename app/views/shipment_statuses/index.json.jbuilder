json.array!(@shipment_statuses) do |shipment_status|
  json.extract! shipment_status, :id, :title
  json.url shipment_status_url(shipment_status, format: :json)
end
