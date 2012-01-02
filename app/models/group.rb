class Group < ActiveRecord::Base
  include Diaspora::Taggable
  include Diaspora::Likeable

  acts_as_taggable_on :tags
  extract_tags_from :description
  before_create :build_tags

  validates :identifier, :presence => true, :length => { :maximum => 64 }, :uniqueness => true
  validates :name, :presence => true, :length => { :maximum => 128 }

  has_many :group_posts
  has_many :posts, :through => :group_posts
end
