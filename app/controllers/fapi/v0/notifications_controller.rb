module Fapi
  module V0
    class NotificationsController < BaseController
      def index
        respond_with( {
          'posts' => @user.notifications.where(:unread => true).order('id DESC')[0..10]
        } )
      end
    end
  end
end
