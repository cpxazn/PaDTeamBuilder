json.array!(@monsters) do |monster|
  json.extract! monster, :id, :name
  json.url monster_url(monster, format: :json)
end
