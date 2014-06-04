class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
    else
      can :create, [BulkMessage, Contact, GroupMessage, Group, List, SingleMessage]
      can [:read, :update, :destroy],
        [BulkMessage, Contact, GroupMessage, Group, List, SingleMessage],
        :user_id => user.id
      can :read, Credit
      cannot [:create, :update, :destroy], Credit
    end
  end
end