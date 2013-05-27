# -*- coding: utf-8 -*-
require_relative "base"

module Albatro
  module Responder
    class WhatResponder < Base
      def dialogue(input, options = {})
        if input.present?
          "#{input}ってなに？"
        end
      end
    end
  end
end

if $0 == __FILE__
  Albatro::Responder::WhatResponder.new.interactive
end
