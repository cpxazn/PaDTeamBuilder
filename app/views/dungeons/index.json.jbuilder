json.array!(@dungeons) do |dungeon|
  json.extract! dungeon, :id, :dungeon_group_id, :name, :stamina, :floors, :coin, :exp, :img
  json.url dungeon_url(dungeon, format: :json)
end
