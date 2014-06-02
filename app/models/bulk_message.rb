class BulkMessage < ActiveRecord::Base
  belongs_to :user

  include Ownable
end
