class ActsAsTaggableOn::Tag

  def followed_count
   @followed_count ||= TagFollowing.where(:tag_id => self.id).count
  end

  def self.tag_text_regexp
    @@tag_text_regexp ||= (RUBY_VERSION.include?('1.9') ? "[[:alnum:]]_-" : "\\w-")
  end

  def self.autocomplete(name)
    where("name LIKE ?", "#{name.downcase}%")
  end

  def self.normalize(name)
    if name =~ /^#?<3/
      # Special case for love, because the world needs more love.
      '<3'
    elsif name
      name.gsub(/[^#{self.tag_text_regexp}]/, '').downcase
    end
  end

  def self.trending
    return []  if ! AppConfig[:trends]

    find_by_sql %{
      SELECT
          id
        , name
      FROM
          v__tags_trending
      ORDER BY
          count DESC
        , most_recent_tagging DESC
      LIMIT 5
    }
  end

  def self.trending_new
    return []  if ! AppConfig[:trends]

    find_by_sql %{
      SELECT
          id
        , name
      FROM
          v__tags_trending_new
      ORDER BY
          count DESC
        , most_recent_tagging DESC
      LIMIT 5
    }
  end
end
