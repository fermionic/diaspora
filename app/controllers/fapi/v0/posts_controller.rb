module Fapi
  module V0
    class PostsController < BaseController
      def index
        respond_with( {
          'posts' => @user.posts.order('id DESC')[0..10]
        } )
      end
    end
  end
end
