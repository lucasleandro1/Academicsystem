json.extract! user, :id, :email, :user_type, :school_id, :active, :created_at, :updated_at
json.url user_url(user, format: :json)
