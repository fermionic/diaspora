class TrendingViewsPostgreSql < ActiveRecord::Migration
  def self.up
    if postgres?
      execute %{
        CREATE VIEW v__tags_trending AS
            SELECT
                  tags.id
                , tags.name
                , COUNT(taggings.*) AS count
            FROM
                  tags
                , taggings
            WHERE
                taggings.tag_id = tags.id
                AND NOW() - taggings.created_at < '24 hours'::INTERVAL
                AND taggings.taggable_type IN ( 'Post', 'Comment' )
            GROUP BY tags.id, tags.name
        ;
      }

      execute %{
        CREATE VIEW v__tags_trending_previous AS
            SELECT
                  tags.id
                , tags.name
                , COUNT(taggings.*) AS count
            FROM
                  tags
                , taggings
            WHERE
                taggings.tag_id = tags.id
                AND NOW() - taggings.created_at >= '24 hours'::INTERVAL
                AND NOW() - taggings.created_at < '7 days'::INTERVAL
                AND taggings.taggable_type IN ( 'Post', 'Comment' )
            GROUP BY tags.id, tags.name
        ;
      }

      execute %{
        CREATE VIEW v__tags_trending_new AS
            SELECT
                  tt.count
                , tt.id
                , tt.name
            FROM
                v__tags_trending tt
            WHERE
                NOT EXISTS (
                    SELECT 1
                    FROM v__tags_trending_previous ttp
                    WHERE ttp.name = tt.name
                    LIMIT 1
                )
        ;
      }
    end
  end

  def self.down
    if postgres?
      execute 'DROP VIEW v__tags_trending_new'
      execute 'DROP VIEW v__tags_trending_previous'
      execute 'DROP VIEW v__tags_trending'
    end
  end
end
