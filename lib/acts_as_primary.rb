require "active_support/dependencies/autoload"
require "active_support/version"
require "active_support/logger"
require "active_support/lazy_load_hooks"
require "active_record"

module ActsAsPrimary
  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern

  autoload :MarkAsPrimary
end
