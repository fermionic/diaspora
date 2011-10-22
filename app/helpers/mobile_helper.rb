# Modified 10/22/2011 Zach Prezkuta
# Disable links to the like function and comment function from the icons for now, since
# the like doesn't update in the desktop view, and commenting from the icon creates a
# new comment right below the post that remains there even when the comments are expanded,
# creating an out-of-place double

module MobileHelper
  def aspect_select_options(aspects, selected)
    selected_id = selected == :all ? "" : selected.id
    '<option value="" >All</option>\n'.html_safe + options_from_collection_for_select(aspects, "id", "name", selected_id)
  end

  def mobile_reshare_icon(post)
    if (post.public? || reshare?(post)) && (user_signed_in? && post.author != current_user.person)
      root = reshare?(post) ? post.root : post

      if root.author != current_user.person.id
        reshare = Reshare.where(:author_id => current_user.person.id,
                                :root_guid => root.guid).first
        klass = reshare.present? ? "active" : "inactive"
        link_to '', reshares_path(:root_guid => root.guid), :title => t('reshares.reshare.reshare_confirmation', :author => root.author.name), :class => "image_link reshare_action #{klass}"
      end
    end
  end

  def mobile_like_icon(post)
    if current_user && current_user.liked?(post)
#      link_to '', post_like_path(post.id, current_user.like_for(post).id), :class => "image_link like_action active"
      html = '<img src="/images/icons/heart_mobile_red.png?1319213932" class="icon">'
    else
#      link_to '', post_likes_path(post.id), :class => "image_link like_action inactive"
      html = '<img src="/images/icons/heart_mobile_grey.png?1319213932" class="icon">'
    end
  end

  def mobile_comment_icon(post)
#    link_to '', new_post_comment_path(post), :class => "image_link comment_action inactive"
    html = '<img src="/images/icons/pencil_mobile_grey.png?1319213932" class="icon">'
  end

  def reactions_link(post)
    reactions_count = post.comments_count + post.likes_count
#    if reactions_count > 0
    if reactions_count >= 0
      link_to "#{t('reactions', :count => reactions_count)}", post_comments_path(post, :format => "mobile"), :class => 'show_comments'
    else
      html = "<span class='show_comments'>"
      html << "#{t('reactions', :count => reactions_count)}"
      html << "</span>"
    end
  end
end
