require File.expand_path(File.join(File.dirname(__FILE__), "responder"))

module Albatro
  class HumanResponder < Responder
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

if $0 == __FILE__
  Albatro::HumanResponder.new.interactive
end
