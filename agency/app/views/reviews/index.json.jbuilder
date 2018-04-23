json.array!(@reviews) do |review|
  json.extract! review, :id, :trip_id, :name, :text
  json.url review_url(review, format: :json)
end
