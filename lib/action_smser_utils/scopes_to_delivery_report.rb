module ActionSmserUtils
  module ScopesToDeliveryReport
    extend ActiveSupport::Concern

    included do
      scope :latest , -> {order(created_at: :desc)}
    end

    module ClassMethods
      def from_user(user)
        where(user.respond_to?(:id) ? {user_id: user.id}: {user: user})
      end
    end
  end
end

ActionSmser::DeliveryReport.send :include, ActionSmserUtils::ScopesToDeliveryReport

