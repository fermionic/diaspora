module Fapi
  module V0
    class NotificationsController < BaseController
      def index
        respond_with( {
          'notifications' => @user.notifications.where(:unread => true).order('id')[0...32]
        } )
      end
    end
  end
end
