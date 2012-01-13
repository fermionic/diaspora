#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Post < ActiveRecord::Base
  include ApplicationHelper

  include Diaspora::Likeable
  include Diaspora::Commentable
  include Diaspora::Shareable

  xml_attr :provider_display_name

  has_many :mentions, :dependent => :destroy

  has_many :reshares, :class_name => "Reshare", :foreign_key => :root_guid, :primary_key => :guid
  has_many :resharers, :class_name => 'Person', :through => :reshares, :source => :author

  belongs_to :o_embed_cache

  after_create :cache_for_author
  after_create :post_to_groups

  #scopes
  scope :includes_for_a_stream, includes(:o_embed_cache, {:author => :profile}, :mentions => {:person => :profile}) #note should include root and photos, but i think those are both on status_message

  def self.excluding_blocks(user)
    ignored_person_ids = user.blocks.includes(:person).map{|b| b.person.id }

    if ignored_person_ids.empty?
      scoped
    else
      where(
        %{
          posts.author_id NOT IN (?)
          AND (
            root_guid IS NULL OR (
              SELECT root_post.author_id
              FROM posts AS root_post
              WHERE root_post.guid = posts.root_guid
            ) NOT IN (?)
          )
        },
        ignored_person_ids,
        ignored_person_ids
      )
    end
  end

  def self.for_a_stream(max_time, order, user=nil)
    scope = self.for_visible_shareable_sql(max_time, order).
      includes_for_a_stream

    scope = scope.excluding_blocks(user) if user.present?

    scope
  end

  #############

  def self.diaspora_initialize params
    new_post = self.new params.to_hash
    new_post.author = params[:author]
    new_post.public = params[:public] if params[:public]
    new_post.pending = params[:pending] if params[:pending]
    new_post.diaspora_handle = new_post.author.diaspora_handle
    new_post
  end

  # @return Returns true if this Post will accept updates (i.e. updates to the caption of a photo).
  def mutable?
    false
  end

  def activity_streams?
    false
  end

  def triggers_caching?
    true
  end

  def comment_email_subject
    I18n.t('notifier.a_post_you_shared')
  end

  # @return [Boolean]
  def cache_for_author
    if self.should_cache_for_author?
      cache = RedisCache.new(self.author.owner, 'created_at')
      cache.add(self.created_at.to_i, self.id)
    end
    true
  end

  # @return [Boolean]
  def should_cache_for_author?
    self.triggers_caching? && RedisCache.configured? &&
      RedisCache.acceptable_types.include?(self.type) && user = self.author.owner
  end

  def hint
    return nil  if text.nil?

    if respond_to?(:strip_tags)
      text_without_tags = strip_tags(text)
    elsif text !~ /[<>]/
      text_without_tags = text
    end

    if text_without_tags.length <= 64
      text_without_tags
    else
      text_without_tags[0...61] + '...'
    end
  end

  def comments_unignored( ignorer )
    @comments_unignored ||= Hash.new
    @comments_unignored[ignorer] ||= comments.including_author.excluding_ignored( ignorer )
  end

  def post_to_groups
    return  if ! self.public
    return  if self.text.nil?

    Group.groups_from_string(self.text).each do |group|
      if author.member_of?(group)
        group.posts << self
      end
    end
  end
end
