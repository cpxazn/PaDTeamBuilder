json.array!(@c_ratings) do |c_rating|
  json.extract! c_rating, :id, :user_id, :comment_id, :score
  json.url c_rating_url(c_rating, format: :json)
end
