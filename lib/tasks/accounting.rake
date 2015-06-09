require "accounting_utils"

def show_info(dlrs)
  users_data = user_info(dlrs)
  accounting = accounting_data(users_data)
  puts "--Accounting--"
  totals = {user: "", billed: 0, cost: 0, profit: 0}
  accounting.each do |data|
    puts data.each_pair.map { |k,v| totals[k]+= v; "#{k}: #{v.to_s.ljust(20)}\t" }.join(" ")
  end
  puts "-" * 20
  puts totals.each_pair.map { |k,v| v="totals" if k == :user; "#{k}: #{v.to_s.ljust(20)}\t" }.join(" ")
end

namespace :accounting do
  desc "Show accounting report for all months"
  task all: :environment do
    show_info(billed_dlrs)
  end

  desc "Show accounting report from given month until now"
  task :from, [:date] => :environment do |t, args|
    begin
      date = Date.parse(args[:date])
      show_info(billed_dlrs.where("created_at >= ?", date))
    rescue Exception => e
      puts "Can not parse the given date"
      puts e.message
    end
  end

  desc "Show accounting report in the given timeframe (start, end)"
  task :between, [:start, :end] => :environment do |t, args|
    begin
      start_date = Date.parse(args[:start])
      end_date = Date.parse(args[:end])
      show_info(billed_dlrs.where(created_at: start_date..end_date))
    rescue Exception => e
      puts "Can not parse the given date"
      puts e.message
    end
  end
end
