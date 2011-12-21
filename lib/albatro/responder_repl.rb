# -*- coding: utf-8 -*-

module Albatro
  module ResponderREPL
    #
    # Responderと会話するデバッグ用CLIインターフェイス
    #
    #   内部コマンド切り替え
    #
    #     / のあとに入力したものはそのまま responder オブジェクトに送る
    #       例: /func #=> self.send(:func)
    #
    #     コマンドの例
    #       /set trace
    #       /unset trace
    #
    #   毎回テストのための発言を入れるのが面倒な場合は？
    #
    #     interactive(:messages => ["a", "b"])
    #     にすると "a" "b" を送って終了する
    #
    def interactive(options = {})
      options = {
        :name => self.class.name.demodulize,
        :tester => "?",
      }.merge(options)

      message_counter = 0

      # puts info
      puts "-" * 80
      loop do
        if options[:messages] && message_counter >= options[:messages].size
          break
        end
        if options[:messages]
          input = options[:messages][message_counter.modulo(options[:messages].size)]
          puts "[#{options[:tester]}] #{input}"
          message_counter += 1
        else
          print "INPUT> "
          input = gets
        end
        input = input.to_s.strip
        if input == "."
          break
        end
        if md = input.match(%r{^/(.*)})
          args = md.captures.first.split(/\s+/)
          begin
            r = send(*args)
            if [String, Integer, Array].include?(r.class)
              puts r
            end
          rescue => error
            p error
          end
          next
        end
        if response = dialogue(input)
          puts "[#{options[:name]}] #{response}"
        end
        if @options[:positivestudy]
          study_from_string(input)
        end
      end
    end

    private

    #
    # boolean型オプションの変更
    #
    # interactiveメソッド内で /set trace や /unset trace を実行できるようにするためにある
    #
    def set(key)
      @options[key.to_sym] = true
    end
    def unset(key)
      @options[key.to_sym] = false
    end
  end
end
