class Group < ActiveRecord::Base
  include Diaspora::Taggable
  include Diaspora::Likeable

  acts_as_taggable_on :tags
  extract_tags_from :description
  before_create :build_tags

  validates :identifier, :presence => true, :length => { :maximum => 64 }, :uniqueness => true
  validates :name, :presence => true, :length => { :maximum => 128 }
  validates :description, :length => { :maximum => 2048 }

  has_many :group_posts
  has_many :posts, :through => :group_posts
  has_many :group_members
  has_many :members, :through => :group_members, :source => :person

  def identifier_full
    self.identifier + '@' + AppConfig[:pod_uri].host
  end
end
