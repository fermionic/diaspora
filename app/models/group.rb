class Group < ActiveRecord::Base
  include Diaspora::Taggable
  include Diaspora::Likeable

  if RUBY_VERSION.include?('1.9')
    VALID_CHARACTERS ="[[:alnum:]]_-"
  else
    VALID_CHARACTERS = "\\w-"
  end

  acts_as_taggable_on :tags
  extract_tags_from :description
  before_create :build_tags

  validates(
    :identifier,
    :presence => true,
    :length => { :maximum => 64 },
    :uniqueness => true,
    :format => { :with => /^[#{VALID_CHARACTERS}]+$/, :message => I18n.t('groups.valid_characters') }
  )
  validates :name, :presence => true, :length => { :maximum => 128 }
  validates :description, :length => { :maximum => 2048 }
  validates :admission, :presence => true, :format => { :with => /^open|on-approval|manual$/ }

  has_many :group_posts
  has_many :posts, :through => :group_posts
  has_many :group_members
  has_many :members, :through => :group_members, :source => :person
  has_many :membership_requests, :class_name => 'GroupMembershipRequest'

  def identifier_full
    self.identifier + '@' + AppConfig[:pod_uri].host
  end
end
