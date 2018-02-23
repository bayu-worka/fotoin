class Moment < ApplicationRecord
  has_many :photos, inverse_of: :moment, dependent: :destroy
  accepts_nested_attributes_for :photos, reject_if: :all_blank, allow_destroy: true
  belongs_to :user

  validates_presence_of :title, :photos, :moment_type
  enum moment_type: [:normal, :donation, :merch]
  
  def root_comments
    Comment.where("commentable_id IN (:photo_ids) AND commentable_type = 'Photo' AND parent_id IS :nil", {photo_ids: photo_ids, nil: nil})
  end

  def vote_for
    ActsAsVotable::Vote.where("votable_id IN (:photo_ids) AND votable_type = 'Photo'", {photo_ids: photo_ids})
  end
end
