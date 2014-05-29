class ReportsController < ApplicationController
  # GET /reports/today
  # GET /reports/today.json
  def today
    @log = []
    1.upto(1000) do |i|
      @log.append(i)
    end
    @log.append(Credit.first)
  end

  # GET /reports/messages
  # GET /reports/messages.json
  def messages
    @log = []
    1.upto(1000) do |i|
      @log.append(Random.srand)
    end
  end

  # GET /reports/messages_summary
  # GET /reports/messages_summary.json
  def summary
    @log = []
    2010.upto(2015) do |i|
      @log.append(i)
    end
  end

  def search_messages
  end
end
