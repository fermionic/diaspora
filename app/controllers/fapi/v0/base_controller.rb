module Fapi
  module V0
    class BaseController < ActionController::Base
      respond_to :json
      before_filter :set_user_from_token

      protected

      def set_user_from_token
        token = params['token']
        @user = User.find_by_api_token(token)
        if token.nil? || @user.nil?
          render :nothing => true, :status => 403
          return
        end

        # Throttling.  Careful when reading this code, the > comparison is a little confusing.
        if @user.api_time_last && @user.api_time_last > 5.seconds.ago
          @user = nil
          render :nothing => true, :status => 503
          return
        end

        @user.api_time_last = Time.now
        @user.save
      end
    end
  end
end
