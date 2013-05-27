require_relative "base"

module Albatro
  module Responder
    class HumanResponder < Base
      def dialogue(input, options = {})
        options = {
          :name => self.class.name,
          :message => nil,
        }.merge(options)
        print "> "
        if str = options[:message]
          puts str
          return str
        end
        str = gets.strip
        if str.present?
          str
        end
      end
    end
  end
end

if $0 == __FILE__
  Albatro::Responder::HumanResponder.new.interactive
end
