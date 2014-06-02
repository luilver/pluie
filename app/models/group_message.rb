class GroupMessage < ActiveRecord::Base
  belongs_to :user

  include Ownable
end
