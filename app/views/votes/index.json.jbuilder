json.array!(@votes) do |vote|
  json.extract! vote, :id, :score
  json.url vote_url(vote, format: :json)
end
