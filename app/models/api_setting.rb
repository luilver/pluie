class ApiSetting < ActiveRecord::Base
  belongs_to :user
  before_create :generate_api_key

  # def valid_secret?(api_secret)
  #   self.api_secret == api_secret
  # end

   private
    def generate_api_key
      begin
        self.api_key = SecureRandom.hex
      end
      while self.class.exists?(api_key: api_key)
     end
    end

end
