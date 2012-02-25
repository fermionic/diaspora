module Fapi
  module V0
    class AspectsController < BaseController
      def index
        respond_with( { 'aspects' => @user.aspects } )
      end
    end
  end
end
