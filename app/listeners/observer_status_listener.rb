class ObserverStatusListener

  def self.default_instance
    @@default_instance ||= ObserverStatusListener.new
  end

  def message_text(key)
    @message_text[key] + " #{I18n.localize(Time.current, :format => :verbose_date_time)}."
  end

  def initialize(text=nil)
    trans = {
      create: "añadido", destroy: "eliminado",
      active:  "activado", deactive: "desactivado"}
    defaults = Hash.new { |hash, key| hash[key] = "Has sido #{trans[key]} como observador." }
    @message_text = defaults.merge(text || {})
  end

  def after_create(observer)
    text = message_text(:create)
    send_sms(text, observer)
  end

  def after_destroy(observer)
    text = message_text(:destroy)
    send_sms(text, observer)
  end

  def after_update(observer)
    v = observer.previous_changes[:active]
    if v && (v[0] != v[1])
      text =  message_text(observer.active ? :active: :deactive)
      send_sms(text, observer)
    end
  end

  private
    def send_sms(text, observer)
      number = observer.gsm_number.number
      job = PluieNotificationSmsJob.new(text, number)
      Delayed::Job.enqueue(job, {queue: 'notifications'})
    end
end
