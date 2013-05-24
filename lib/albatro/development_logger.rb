require_relative "logger"
Albatro.logger ||= ActiveSupport::BufferedLogger.new(File.expand_path(File.join(File.dirname(__FILE__), "../../log/development.log")))

if $0 == __FILE__
  Albatro.logger.debug("OK1")
  Albatro.logger.silence do
    Albatro.logger.debug("OK2")
  end
  Albatro.logger.debug("OK3")
  Albatro.logger.level = ActiveSupport::BufferedLogger::INFO
  Albatro.logger.debug("OK4")
end
