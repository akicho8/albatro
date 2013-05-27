# -*- coding: utf-8 -*-

require "bundler/setup"
Bundler.require

Albatro.logger = ActiveSupport::BufferedLogger.new(File.expand_path(File.join(File.dirname(__FILE__), "log/development.log")))

require "observer"

require_relative "sound_observer"
require_relative "talk_client"

module Chat
  class SilentRoom
    include Observable

    attr_accessor :members
    attr_accessor :response
    attr_accessor :current
    attr_accessor :options

    def self.open(*args, &block)
      new(*args).tap{|object|object.open(&block)}
    end

    def self.single_open(options)
      open(:name => "#{options[:bot].name}専用"){|room|
        room.join(options[:bot])
        room.main_loop(:max => options[:max]){room.alone}
      }
    end

    def initialize(options = {})
      @options = {
        :verbose => true,
        :name => "#{object_id}号室",
      }.merge(options)

      @console = Chat::Console.new
      add_observer(@console)

      @members = []

      @current = nil
      @response = nil
    end

    def open(&block)
      changed
      notify_observers(:open, "<< #{name}を開きました >>")
      if block_given?
        begin
          yield self
        ensure
          close
        end
      end
      self
    end

    def close
      changed
      notify_observers(:close, "<< #{name}を閉じました >>")
    end

    def name
      @options[:name]
    end

    # チャットに入っている人の名前一覧
    def member_names
      @members.collect{|member|member.params[:name]}
    end

    def join(member)
      raise "すでに入ってます" if @members.include?(members)
      @current ||= member
      @members << member
      member.join(self)
      changed
      notify_observers(:join, "<< #{member.name}さんが入室されました >>")
    end

    def others
      @members - [@current]
    end

    def last_response
      @response
    end

    def last_response_clear
      @response = nil
    end

    # 学習したい人は全員学習する
    def learn_all
      if @response
        others.each{|other|other.study_from(@response.to_s)}
      end
    end

    def turn_onece
      unless @current
        Albatro.logger.debug("部屋に誰もいません") if Albatro.logger
        throw :exit
      end

      Albatro.logger.debug("[#{Time.now.to_s(:db)}] #{@current.info} の '#{@response}' に対する反応") if Albatro.logger
      @response = @current.dialogue(@response.to_s)
      if @response == "."
        throw :exit
      end

      if @response
        changed
        notify_observers(:say, @current.params[:name], @response.to_s, :member_names => member_names)
      end

      @console.sync_wait
    end

    # 次のターンにする(抽象メソッド)
    def next_turn
      switch_next_member
    end

    # 次のメンバーに切り替える
    def switch_next_member
      @current = @members[@members.index(@current).next.modulo(@members.size)]
    end

    # 自分以外のメンバーをランダムで選択
    def _switch_other_member
      if other = others.choice
        @current = other
      end
    end

    # ランダムでメンバーを選ぶ
    def switch_random_member
      @current = @members.sample
    end

    # 会話のループに入る
    #
    # 会話する場合
    # main_loop
    #
    # 一人でしゃべる場合
    # main_loop(:max => 10){room.alone}
    #
    def main_loop(options = {}, &block)
      options = {
        :max => 30,
      }.merge(options)
      count = 0
      catch(:exit) do
        loop do
          if options[:max] && count >= options[:max]
            break
          end
          if block_given?
            yield self
          else
            everyone_talk
          end
          count += 1
        end
      end
    end

    # 大勢で会話
    def everyone_talk
      turn_onece
      learn_all
      next_turn
    end

    # 独りでしゃべる場合
    def alone
      turn_onece
      last_response_clear # 自分の発言をクリア
    end
  end

  class VipRoom < SilentRoom
    def initialize(*)
      super
      @console.sleep_time1 = 1.0
      @console.sleep_time2 = 1.0

      # add_observer(Chat::SoundObserver.new)
      add_observer(Chat::TalkClient.new)
    end
  end

  class Console
    attr_accessor :sleep_time1, :sleep_time2

    def update(command, *args)
      case command
      when :say
        prompt, message = chat_post_message(*args)
        if @sleep_time2.to_f.zero?
          puts "#{prompt}#{message}"
        else
          sync_wait
          @thread = Thread.start do
            Albatro.logger.debug([:thread_start, message].inspect) if Albatro.logger
            chars = message.scan(/./)
            print prompt
            STDOUT.flush
            chars.each{|ch|
              print ch
              STDOUT.flush
              sleep(@sleep_time2.to_f / chars.size)
            }
            puts
            # sleep(@sleep_time1.to_f)
          end
        end
      else
        puts args.to_s
      end
    end

    def sync_wait
      if @thread
        @thread.join
        Albatro.logger.debug([:thread_join].inspect) if Albatro.logger
      end
    end

    private

    #
    # 配列の中の文字列から最長の幅を取得
    #
    def max_width(array)
      array.collect{|item|item.to_s.kconv(Kconv::EUC, Kconv::UTF8).size}.max
    end

    def chat_post_message(handle_name, message, options = {})
      options = {
        :left_margin => 2,
      }.merge(options)
      if options[:member_names]
        max_width = max_width(options[:member_names])
      else
        max_width = max_width([handle_name])
      end
      handle_name = handle_name.to_s.kconv(Kconv::EUC, Kconv::UTF8).rjust(max_width).kconv(Kconv::UTF8, Kconv::EUC)
      [" " * options[:left_margin] + handle_name + ": ", message]
    end
  end

  class SimpleBot
    attr_accessor :params, :responder

    def initialize(params = {})
      @params = {
        :may_study => false, # 会話中、自主的に学習するか？
        :dopt => proc{{}},
      }.merge(params)

      @responder = params[:responder]
    end

    def setup(chat_room)
      if params[:dicname].present?
        unless @responder.respond_to?(:load)
          study_from_file
        else
          @responder.options[:database] = File.expand_path(File.join(File.dirname(__FILE__), "tmp/#{name}_in_#{chat_room.name}.db".underscore))
          if @responder.database.exist?
            @responder.load
            puts "ロード... #{info}"
          else
            study_from_file
            @responder.save

            # puts "save: #{@responder.database.basename}"
            file = File.expand_path(File.join(File.dirname(__FILE__), "tmp/#{name}_in_#{chat_room.name}.png".underscore))
            @responder.to_dot(:root_label => "スタート", :file => file, :rankdir => "LR", :fontsize => 14, :concentrate => true)

            file = Pathname(File.expand_path(File.join(File.dirname(__FILE__), "tmp/#{name}_in_#{chat_room.name}.dot".underscore)))
            str = @responder.to_dot(:root_label => "スタート", :rankdir => "LR", :fontsize => 14, :concentrate => true)
            FileUtils.makedirs(file.dirname)
            file.open("w"){|f|f << str}
          end
        end
      end
    end

    def study_from_file
      Array.wrap(params[:dicname]).each{|dicname|
        dic_file = Pathname(File.expand_path(File.join(File.dirname(__FILE__), "../resources/#{dicname}.txt")))
        puts "学習中... (#{dic_file.basename('.*')})"
        @responder.study_from(:file => dic_file, :format => @params[:format])
      }
    end

    def name
      @params[:name]
    end

    def info
      "#{name} (#{self.class.name}) #{@responder.info}"
    end

    #
    # inputに対する返答を返す
    #
    # @params[:name] を渡しているのは Responder::HumanResponder に名指しさせるため
    # その処理は、こっちの方で表示してもいいかもしれない。
    #
    def dialogue(input)
      @responder.dialogue(input, @params[:dopt].call.merge(:name => name))
    end

    # チャットに入ったときに呼ばれるコールバック
    def join(chat_room)
      setup(chat_room)
    end

    # チャットで前の人の発言を学習したかったら覚える
    def study_from(input)
      if @params[:may_study]
        @responder.study_from(input)
      end
    end
  end
end

if $0 == __FILE__
  Chat::VipRoom.open{|room|
    room.join(Chat::SimpleBot.new(:responder => Albatro::Responder::WhatResponder.new, :name => "まゆしぃ"))
    room.join(Chat::SimpleBot.new(:responder => Albatro::Responder::ActorResponder.new(:messages => ["あいうえお", "."]), :name => "おかりん"))
    room.main_loop
  }
end
