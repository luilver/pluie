class ApiSetting < ActiveRecord::Base
  belongs_to :user
  before_create :generate_api_key_atribute

  # def valid_secret?(api_secret)
  #   self.api_secret == api_secret
  # end

  def reset_authentication_token!
     self.api_key= generate_api_key1
     self.save
     return generate_api_key1
  end

   private
    # def generate_api_key
    #   begin
    #     self.api_key = SecureRandom.hex
    #   end
    #   while self.class.exists?(api_key: api_key)
    #
    #  end
    # end

  def generate_api_key1
    loop do
      token = SecureRandom.hex
      break token unless ApiSetting.where(api_key: token).first
    end
  end

  def generate_api_key_atribute
      self.api_key= generate_api_key1
  end

  def self.generate_email_knales()
      loop do
         email = (0...6).map {('0'..'9').to_a.concat(('a'..'z').to_a)[rand(35)]}.join
         email=email+'@knal.es'
         break email unless User.where(:email=>email).first
      end
  end

  def self.generate_password_knales()
   password= (0...8).map {('0'..'9').to_a.concat(('a'..'z').to_a)[rand(35)]}.join
   return password
  end
end
