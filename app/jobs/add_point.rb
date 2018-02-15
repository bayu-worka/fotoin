class AddPoint
  include Sidekiq::Worker

  def perform(*args)
    User.find_each do |user|
      user.add_point_last_month
    end
  end
end
