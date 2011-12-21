require "active_support/buffered_logger"
require "active_support/core_ext/module"
require "fileutils"

module Albatro
  mattr_accessor :logger
end

if $0 == __FILE__
  Albatro.logger = ActiveSupport::BufferedLogger.new(File.expand_path(File.join(File.dirname(__FILE__), "../../log/development.log")))

  Albatro.logger.debug("OK1")
  Albatro.logger.silence do
    Albatro.logger.debug("OK2")
  end
  Albatro.logger.debug("OK3")
  Albatro.logger.level = ActiveSupport::BufferedLogger::INFO
  Albatro.logger.debug("OK4")
end
