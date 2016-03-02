json.array!(@vote_lls) do |vote_ll|
  json.extract! vote_ll, :id, :leaders, :user_id, :score
  json.url vote_ll_url(vote_ll, format: :json)
end
