class BulkMsgReceiversCounter
  def self.count(bulk_msg)
    bulk_msg.receivers.size
  end
end
