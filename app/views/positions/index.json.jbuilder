json.array!(@positions) do |position|
  json.extract! position, :id, :long, :lat, :dest, :prev_dest, :last_port, :eta, :nav_status, :last_upt
  json.url position_url(position, format: :json)
end
