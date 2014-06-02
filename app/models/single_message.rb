class SingleMessage < ActiveRecord::Base
  belongs_to :user

  include Ownable
end
