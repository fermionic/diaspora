module Fapi
  module V0
    class BaseController < ActionController::Base
      respond_to :json
      before_filter :set_user_from_token

      protected

      # TODO: Throttle

      def set_user_from_token
        token = params['token']
        @user = User.find_by_token_api(token)
        if token.nil? || @user.nil?
          render :nothing => true, :status => 403
        end
      end
    end
  end
end
