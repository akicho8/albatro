# -*- coding: utf-8 -*-
require "drb/drb"
object = DRbObject.new_with_uri("druby://192.168.11.63:50100")
object.talk("接続できた。問題ない", "78 -1 20 0") # 速度(50-300) 音程(50-200) 音量(1-100) 音質(1-8)
