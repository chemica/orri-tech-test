json.extract! user, :id, :name, :stars, :created_at, :updated_at
json.url user_url(user, format: :json)
