class Postzord::Dispatcher::PodOnly < Postzord::Dispatcher

  # @param user [User] User dispatching the object in question
  # @param object [Object] The object to be sent to other Diaspora installations
  # @opt additional_subscribers [Array<Person>] Additional subscribers
  def initialize(user, object, opts={})
    @sender = user
    @object = object
    @xml = @object.to_diaspora_xml
    @subscribers = subscribers_from_object
  end

  # @param user [User]
  # @param activity [String]
  # @return [Salmon::EncryptedSlap]
  def self.salmon(user, activity)
    Salmon::Slap.create_by_user_and_activity(user, activity)
  end

  # @param person [Person]
  # @return [String]
  def self.receive_url_for(person)
    person.receive_url
  end
end
