# -*- coding: utf-8 -*-

module Albatro
  module ResponderUtils
    #
    # 配列から一つランダムに一つを返すユーティリティメソッド
    #
    #   p array_sample(["A", "B", "C"])                          #=> "B"
    #   p array_sample(["A", "B", "C"], :sample_at => :first) #=> "A"
    #   p array_sample(["A", "B", "C"], :sample_at => :last   #=> "C"
    #
    def array_sample(array, options = {})
      options = {
      }.merge(options)
      case v = options[:sample_at]
      when :first, :last, :sample
        array.public_send(v)
      when Integer
        array.at(v)
      else
        raise ArgumentError, "曖昧さを回避するため options[:sample_at] を明示的に指定してください (:first, :last, :sample)"
      end
    end

    #
    # 配列をシャッフルするユーティリティメソッド
    #
    #   p array_shuffle(["A", "B", "C"]) #=> ["C", "A", "B"]
    #
    def array_shuffle(array, options = {})
      raise "使用禁止"
      options = {
        :shuffle_logic => @options[:shuffle_logic],
      }.merge(options)
      case options[:shuffle_logic]
      when :untouch
        array
      when :random
        array.shuffle
      else
        raise ArgumentError, "options[:shuffle_logic]"
      end
    end
  end
end
