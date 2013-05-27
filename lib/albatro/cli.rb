# -*- coding: utf-8 -*-
# -*- compile-command: "ruby -I.. cli.rb --database _test.db --study=アヒルと鴨のコインロッカー --dump --say=アヒル --generate=2 --info --save" -*-
# -*- compile-command: "ruby -I.. cli.rb --database bocchan.db --read=bocchan.txt --save" -*-
# -*- compile-command: "ruby -I.. cli.rb --database yoshinoya.db --clear --study='私は鳥になります' --count 8 --save" -*-
# -*- compile-command: "ruby -I.. cli.rb --clear --read=bocchan.txt --verbose --count 8" -*-
# -*- compile-command: "ruby -I.. cli.rb --tree" -*-
# -*- compile-command: "ruby -I.. cli.rb --clear --studybyweb=初音ミク --count 8" -*-
# -*- compile-command: "ruby -I.. cli.rb --clear --read=bocchan_mini.txt --count 8" -*-
# -*- compile-command: "ruby -I.. cli.rb --responder=what --say=こんにちは" -*-

require_relative "../albatro"

require "optparse"

module Albatro
  class CLI
    def self.execute(args = ARGV)
      @responder = Responder::MarkovResponder.new # デフォルト
      @oparser = OptionParser.new{|@oparser|
        @oparser.version = "0.1.0"
        @oparser.banner = [
          "人工無能アルゴリズムテスト #{@oparser.ver}",
          "使い方: #{@oparser.program_name} <命令>",
        ].collect{|e|e + "\n"}
        @oparser.separator("命令")
        @oparser.on("-i", "--interactive", "対話モード", TrueClass){@responder.interactive}
        @oparser.on("-d", "--database=DBFILE", "データベースファイル", String){|database|
          @responder.options[:database] = Pathname(database).expand_path
        }
        @oparser.on("-l", "--load", "データベースからロード", TrueClass){@responder.load}
        @oparser.on("-s", "--save", "データベースに保存", TrueClass){@responder.save}
        @oparser.on("-r", "--read=FILENAME", "テキスト学習", String){|filename|@responder.study_from(:file => filename)}

        @oparser.on("--info", "現在の状態を表示", TrueClass){puts @responder.info}
        @oparser.on("--tree", "木構造の表示", TrueClass){puts @responder.tree}
        @oparser.on("--dump", "辞書をrubyコード化", TrueClass){pp @responder.tree_dump}
        @oparser.on("--clear", "学習破棄", TrueClass){@responder.clear}

        @oparser.on("-t", "--[no-]trace", "トレースモード", TrueClass){|value|@responder.options[:trace] = value} # {|@responder.options[:trace]|} とした場合 ruby_parser で失敗する
        @oparser.on("--[no-]positivestudy", "相手の発言から学習するか？(初期値:#{@responder.options[:positivestudy]})", TrueClass){|value|@responder.options[:positivestudy] = value}
        @oparser.on("--[no-]uniquesuffix", "マルコフ辞書のサフィックスをユニークにして学習するか？(初期値:#{@responder.options[:uniquesuffix]})", TrueClass){|value|@responder.options[:uniquesuffix] = value}

        @oparser.separator("発言取得系")
        @oparser.on("--say=STRING", "指定の発言に対する反応", String){|say|
          if res = @responder.dialogue(say)
            puts "#{res}"
          end
        }
        @oparser.on("--responseby=STRING,COUNT", "指定の発言に対する反応を指定件数求める", String){|arg|
          say, count = arg.split(",")
          puts @responder.responseby(say, :loop => count.to_i, :break => false)
        }
        @oparser.on("--study=TEXT", "学習する文章", String){|study|
          @responder.study_from(:text => study)
        }
        @oparser.on("--prefix=COUNT", "マルコフモデルでプレフィクス数", Integer){|count|
          @responder.options[:prefix] = count
        }
        @oparser.on("--generate=COUNT", "指定の数だけ自由に発言を求める", Integer){|count|
          puts @responder.gather_newstopics(count)
        }

        @oparser.separator("特殊命令")
        @oparser.on("--responder=STRING", "アルゴリズム(初期値: #{@responder.class.name.gsub(/Responder/, '')})", String){|responder|
          @responder = "albatro/#{responder}_responder".underscore.classify.constantize.new
        }
        @oparser.on("--studybyweb=STRING", "指定の検索後に関連する言葉で学習する", String){|studybyweb|
          require "google-search"
          require "nokogiri"
          Google::Search::Web.new(:query => studybyweb).each{|record|
            doc = Nokogiri(record.content)
            @responder.study_from_string(doc.text, :trace => true)
          }
        }
      }

      if args.empty?
        if false
          @responder.options[:positivestudy] = true
          @responder.interactive
        else
          puts @oparser
          exit(1)
        end
      end

      begin
        @oparser.parse!(args)
      rescue OptionParser::InvalidOption => error
        puts error
        exit(1)
      end
    end
  end
end

if $0 == __FILE__
  Albatro::CLI.execute
end
