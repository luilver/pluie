require 'action_smser_utils'

class ScheduleSmsJob
  def initialize(command,message,backup,random)
    @command=command
    @message=message
    @backup=backup
    @randomtext=random
  end

  def perform
    @command.deliver(@message,@backup,@randomtext)
  end
end
