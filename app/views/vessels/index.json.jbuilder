json.array!(@vessels) do |vessel|
  json.extract! vessel, :id, :vsl_name, :vsl_type, :blt_year, :vsl_flag
  json.url vessel_url(vessel, format: :json)
end
