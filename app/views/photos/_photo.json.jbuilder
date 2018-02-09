json.extract! photo, :id, :image, :description, :user_id, :created_at, :updated_at
json.url photo_url(photo, format: :json)
