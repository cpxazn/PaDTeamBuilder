json.array!(@comments) do |comment|
  json.extract! comment, :id, :user_id, :leader_id, :sub_id, :comment, :parent_id
  json.url comment_url(comment, format: :json)
end
