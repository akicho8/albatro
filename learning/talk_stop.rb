# -*- coding: utf-8 -*-
require_relative 'talk_client'
object = Chat::TalkClient.new
# object.talk("ちゃんと繋がってる。問題ない1", :sync => false)
# object.talk("ちゃんと繋がってる。問題ない2", :sync => false)
# object.talk("ちゃんと繋がってる。問題ない3", :sync => false)
# sleep(2)
puts object.remote_talk("/Clear") # 次の行以降をクリア
puts object.remote_talk("/Skip")  # 現在の行をスキップ
