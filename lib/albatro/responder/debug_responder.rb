require_relative "base"

module Albatro
  module Responder
    class DebugResponder < Base
      def dialogue(*args)
        args.inspect
      end
    end
  end
end

if $0 == __FILE__
  Albatro::Responder::DebugResponder.new.interactive
end
