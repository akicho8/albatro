# -*- coding: utf-8 -*-
# 応答クラスのテンプレート

require File.expand_path(File.join(File.dirname(__FILE__), "responder_utils"))
require File.expand_path(File.join(File.dirname(__FILE__), "responder_repl"))
require File.expand_path(File.join(File.dirname(__FILE__), "logger"))

module Albatro
  class Responder
    include ResponderUtils
    include ResponderREPL

    attr_accessor :options, :dictionary

    def initialize(options = {})
      @options = default_options.merge(options)
      @dictionary = nil
    end

    #
    # 内部共通オプション
    #
    # あまり増やすとグローバル変数が大量にある状態になって使いにくくなるので追加の際にはよく検討すること
    #
    def default_options
      {
        :trace => false,
        :positivestudy => false,
      }
    end

    #
    # input に対して自ら進んで言及できるか？
    #
    def refer?(input, options = {})
      false
    end

    #
    # input に対して言及する
    #
    # refer? で true を返して dialogue で言及できなくてもよい。
    # その逆も可。
    #
    #   p dialogue("いい天気ですね") #=> "そうですね"
    #
    def dialogue(input, options = {})
    end

    #
    # 話題を変えて発言する
    #
    #   p generate #=> "いい天気ですね"
    #
    def generate(options = {})
    end

    #
    # 学習した内容をすべて忘れる
    #
    def clear
    end

    #
    # 何かから自動的に読み込んで学習する
    #
    #   study_from("ファミコン")                               ; この一行だけを学習するとくに変換はしない(サブクラスによっては分解するかもしれない)
    #   study_from(:string => "ファミコン")                    ; study_from("ファミコン") と同じ
    #   study_from(:text => "...\n...\n...")                   ; 文字コードもよくわからない巨大なテキスト。分解される。
    #   study_from(:file => "../source.txt")                   ; ファイルパスの場合
    #   study_from(Pathname("../source.txt"))                  ; ファイルから学習(read メソッドがあるものならなんでもいい)
    #   study_from(URI("http://www.google.co.jp/?q=初音ミク")) ; ネットから学習(read メソッドがあるものならなんでもいいので)
    #
    def study_from(arg)
      if arg.respond_to?(:read) # for IO, Pathname
        study_from_text(arg.read)
        return
      end
      case arg
      when Hash
        if arg[:text]
          study_from_text(arg[:text])
        elsif arg[:file]
          file = Pathname(arg[:file]).expand_path
          if arg[:format].to_s == "lines"
            study_from(file.readlines)
          else
            study_from(file)
          end
        elsif arg[:string]
          study_from(arg[:string])
        else
          raise ArgumentError, "#{arg.inspect}"
        end
      when Array
        arg.each{|line|study_from(line)}
      when String
        study_from_string(arg)
      else
        raise ArgumentError, "#{arg.inspect}"
      end
    end

    #
    # 指定の文字列から学習する
    #
    #   study_from_string("昨日、近所の吉野家行ったんです。")
    #
    def study_from_string(line)
    end

    #
    # 応答オブジェクトの情報を一行で返す
    #
    #   p info #=> "[Responder] 語彙数:32768"
    #
    def info
      "[#{self.class.name}]"
    end

    # 発言に対するレスポンスを返す(高レベルメソッド)
    def responseby(input, options = {})
      options = {
        :loop => 1,     # 何件レスポンスするか？
        :break => true, # 1件レスポンスしたら処理を戻す
      }.merge(options)
      out = []
      options[:loop].times{
        if response = dialogue(input, :rescue_silent => options[:rescue_silent])
          out << "#{response}"
          if options[:break]
            break
          end
        end
      }
      out
    end

    private

    #
    # でっかいテキストは綺麗にしてから学習する
    #
    def study_from_text(text)
      text = text.to_s.toutf8.gsub(/^#.*\r?\n/, "")
      Morpheme.instance.text_to_sentences(text).each{|one|
        study_from_string(one)
      }
    end
  end
end

if $0 == __FILE__
  class C < Albatro::Responder
    def dialogue(input, options = {})
      input.inspect
    end
  end
  C.new.interactive(:messages => ["ok"])
end

