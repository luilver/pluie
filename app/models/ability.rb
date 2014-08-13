class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.current
    if user.admin?
      can :manage, :all
    else
      can :create, [BulkMessage, Contact, GroupMessage, Group, List, SingleMessage]
      can [:read, :update, :destroy],
        [BulkMessage, Contact, GroupMessage, Group, List, SingleMessage],
        :user_id => user.id

      can :read, Credit, :user_id => user.id
      cannot [:create, :update, :destroy], Credit

      can :read, ActionSmser::DeliveryReport, :user_id => user.id
      cannot [:create, :update, :destroy], ActionSmser::DeliveryReport

      can :balance, User, :user_id => user.id
    end
  end
end
