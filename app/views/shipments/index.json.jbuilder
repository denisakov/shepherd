json.array!(@shipments) do |shipment|
  json.extract! shipment, :id, :title
  json.url shipment_url(shipment, format: :json)
end
