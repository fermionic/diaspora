class UpdateTrendingViewsPostgresql < ActiveRecord::Migration
  def self.up
    return  if ! postgres?

    execute %{
      CREATE VIEW v__post_comment_taggings_tags_authors AS
          SELECT
                t.id AS tag_id
              , t.name AS tag_name
              , tgs.created_at AS created_at
              , COALESCE(
                  ( SELECT p.author_id FROM posts p WHERE tgs.taggable_type = 'Post' AND p.id = tgs.taggable_id ),
                  ( SELECT c.author_id FROM comments c WHERE tgs.taggable_type = 'Comment' AND c.id = tgs.taggable_id )
              ) AS author_id
          FROM
                tags     t
              , taggings tgs
          WHERE
              tgs.tag_id = t.id
              AND tgs.taggable_type IN ( 'Post', 'Comment' )
      ;
    }

    execute %{
      CREATE OR REPLACE VIEW v__tags_trending AS
          SELECT
                tag_id   AS id
              , tag_name AS name
              , COUNT(DISTINCT author_id) AS count
              , MAX(created_at) AS most_recent_tagging
          FROM
              v__post_comment_taggings_tags_authors
          WHERE
              NOW() - created_at < '24 hours'::INTERVAL
          GROUP BY
              tag_id, tag_name
      ;
    }

    execute %{
      CREATE OR REPLACE VIEW v__tags_trending_previous AS
          SELECT
                tag_id   AS id
              , tag_name AS name
              , COUNT(DISTINCT author_id) AS count
              , MAX(created_at) AS most_recent_tagging
          FROM
              v__post_comment_taggings_tags_authors
          WHERE
              NOW() - created_at >= '24 hours'::INTERVAL
              AND NOW() - created_at < '7 days'::INTERVAL
          GROUP BY
              tag_id, tag_name
      ;
    }

    execute %{
      CREATE OR REPLACE VIEW v__tags_trending_new AS
          SELECT
                tt.count
              , tt.id
              , tt.name
              , tt.most_recent_tagging
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

  def self.down
      return  if ! postgres?

      execute 'DROP VIEW v__tags_trending_new'
      execute 'DROP VIEW v__tags_trending_previous'
      execute 'DROP VIEW v__tags_trending'

      execute %{
        CREATE OR REPLACE VIEW v__tags_trending AS
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
        CREATE OR REPLACE VIEW v__tags_trending_previous AS
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
        CREATE OR REPLACE VIEW v__tags_trending_new AS
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

      execute "DROP VIEW v__post_comment_taggings_tags_authors"
  end
end
