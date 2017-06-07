# == Schema Information
#
# Table name: logging_entries
#
#  id         :integer          not null, primary key
#  severity   :integer          default("info")
#  message    :text
#  backtrace  :text
#  created_at :datetime
#

class LoggingEntry < ApplicationRecord
  SEVERITIES = [:info, :debug, :warn, :error, :fatal, :unknown].freeze
  enum severity: SEVERITIES
  class LoggerProxy
    def initialize(log, level = DEBUG)
      @level = level
    end

    SEVERITIES.each do |s|
      class_eval <<-EOT, __FILE__, __LINE__ + 1
        def #{s}(message = nil, progname = nil, &block)
          my_add(:#{s}, message, progname, caller, &block)
        end
        def #{s}?
          #{SEVERITIES.index(s)} >= @level
        end
      EOT
    end

    def add(severity, message = nil, progname = nil, &block)
      my_add(severity, message, progname, caller, &block)
    end

    def my_add(severity, message = nil, progname = nil, callee = nil, &block)
      return if @level > SEVERITIES.index(severity)
      message = (message || (block && block.call) || progname).to_s
      LoggingEntry.create(severity: severity, message: message, backtrace: callee.reject { |i| i['gems'] || i['/ruby/'] }.join("\n"))
    end

    def level
      @level
    end

    def formatter
    end
  end
end
