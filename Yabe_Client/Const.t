﻿var Cy_夜神路径 // 夜神other的路径
var Cy_OrderPath // 訂單ini路徑

var C_配置路径 = "C:\\Status.ini" //放置夜神Nox.exe和 待發的路徑
//var C_YabeWeb=C_YabeWeb & ""
//var C_YabeWeb = "http://d.yabeline.tw/"
var C_调试 = false
var C_YabeWeb = "https://yabeline.tw/"
//var C_调试 = false
var C_待送国家 = array()

var Cw_国家网址 = array()
var C_国家英文 = array()

var c_Error = array()
var C_运作路径  //C_Noxshare & C_帐密[0] & "Run.txt"
var C_个别资料夹

var C_DB_Path
var C_DB_OrderPath
var C_DB_Error2_Path // 異常2次數訂單

var C_订单数量 = 0
var C_回报失败次数 = 0
var C_重开次数 = 0// 主线程卡死几次
var C_订单发送时间
var C_App运行时间 //上次App运行时间距离现在多久
var C_Debug_取资料时间
var C_版本号 = 10