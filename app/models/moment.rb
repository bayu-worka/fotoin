class Moment < ApplicationRecord
  default_scope {order(created_at: :desc)}
  has_many :photos, inverse_of: :moment, dependent: :destroy
  with_options dependent: :destroy do |assoc|
    assoc.has_many :donations
    assoc.has_many :orders
  end

  accepts_nested_attributes_for :photos, reject_if: :all_blank, allow_destroy: true
  belongs_to :user

  validates_presence_of :title, :photos, :moment_type
  validates_presence_of :price, if: :merch?

  enum moment_type: [:normal, :donation, :merch]
  
  def root_comments
    Comment.where("commentable_id IN (:photo_ids) AND commentable_type = 'Photo' AND parent_id IS :nil", {photo_ids: photo_ids, nil: nil})
  end

  def vote_for
    ActsAsVotable::Vote.where("votable_id IN (:photo_ids) AND votable_type = 'Photo'", {photo_ids: photo_ids})
  end

  def self.payable
    where("moment_type = 1 OR moment_type = 2")
  end

  def total_donation
    donations.sum(&:amount)
  end
end
