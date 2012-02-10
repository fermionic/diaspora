module Fapi
  module V0
    class MeController < BaseController
      def show
        respond_with( { 'username' => @user.username } )
      end
    end
  end
end
