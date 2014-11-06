json.array!(@owners) do |owner|
  json.extract! owner, :id, :name, :rus_name, :contact, :notes
  json.url owner_url(owner, format: :json)
end
