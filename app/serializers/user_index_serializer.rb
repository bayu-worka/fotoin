class UserIndexSerializer < ActiveModel::Serializer
  attributes :id, :email, :phone, :point, :follow_status


  def follow_status
    if scope
      scope[:current_user].following?(object)
    else
      nil
    end
  end
end
