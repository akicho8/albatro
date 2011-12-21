require File.expand_path(File.join(File.dirname(__FILE__), "responder"))

module Albatro
  class DebugResponder < Responder
    def dialogue(*args)
      args.inspect
    end
  end
end

if $0 == __FILE__
  Albatro::DebugResponder.new.interactive
end
