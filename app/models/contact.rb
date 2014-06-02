class Contact < ActiveRecord::Base
  belongs_to :user

  include Ownable
end
