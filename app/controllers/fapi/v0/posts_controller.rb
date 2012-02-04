module Fapi
  module V0
    class PostsController < BaseController
      def index
        respond_with( {
          'posts' => @user.posts.order('id DESC')[0..10]
        } )
      end

      def create
        msg = @user.build_post(
          :status_message,
          {
            'aspect_ids' => ['public'],
            'text'       => params['text'],
          }
        )
        msg.public = true
        msg.save

        aspect_ids = @user.aspects.map{|a| a.id}
        aspects = @user.aspects_from_ids(aspect_ids)
        @user.add_to_streams(msg, aspects)

        # receiving_services = @user.services.where(:type => params[:services].map{|s| "Services::"+s.titleize}) if params[:services]
        # @user.dispatch_post(msg, :url => short_post_url(msg.guid), :services => receiving_services)

        @user.dispatch_post(msg, :url => short_post_url(msg.guid))

        render :nothing => true
      end
    end
  end
end
