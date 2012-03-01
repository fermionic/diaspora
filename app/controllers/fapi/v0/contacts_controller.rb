module Fapi
  module V0
    class ContactsController < BaseController
      # Includes full people (person) records, as well
      def index
        contacts = @user.contacts.map { |c|
          h = c.as_json
          h['contact']['person'] = c.person.as_json
          h
        }

        respond_with( { 'contacts' => contacts } )
      end
    end
  end
end
