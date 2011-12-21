# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "talk_client"))
object = Chat::TalkClient.new
object.talk("長い時間おつきあい、ありがとうございました。何か質問ありますか？", :sync => true)
sleep(3)
object.talk("ないですね")
