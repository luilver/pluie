module ActionSmser
  module DeliveryReportsHelper
    def dr_summary_url(new_params)
      main_app.summary_delivery_reports_url({:time_span => params[:time_span], :gateway => params[:gateway], :redeliveries => params[:redeliveries]}.merge(new_params))
    end
  end
end
