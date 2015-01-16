class CreateTopupCommand
  include Wisper::Publisher

  def execute(user, attributes)
    topup = Topup.new(attributes)
    topup.user = user
    if topup.save
      publish(:success, topup)
    else
      publish(:failure, topup)
    end
  end
end
