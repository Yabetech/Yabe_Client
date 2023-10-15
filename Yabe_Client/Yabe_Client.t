变量 C_帐密 = 数组()
变量 C_国家
变量 C_Web
变量 C_网域
变量 主线程, 监测线程, 窗口跟随线程
变量 C_Noxshare
变量 C_订单标志 = 假
变量 临时线程句柄, Global_源码开关
变量 C_跟随 = 真
功能 Yabe_Client_初始化()
    变量 局_开始 = 假
    变量 局_参数 = 获取参数ex()
    //traceprint(动态库调用("user32.dll","int","GetSystemMetrics","int",80))
    FireBase_时间 = 当前时间()
    
    
    如果(数组大小(局_参数) > 1)
        C_帐密[0] = 局_参数[1]
        C_帐密[1] = 局_参数[2]
        C_帐密["id"] = 局_参数[3]
        
        //                var 局_例外 = array("iyabe14","iyabe15","iyabe16")
        //                if(arrayfindvalue(局_例外,C_帐密[0]))
        //窗口定位(局_参数)
        //                end
        
        wlog("初始化", "帳號:" & C_帐密[0] & ",ID:" & C_帐密["id"])
        局_开始 = 真
    否则
        C_帐密[0] = "iyabe42"
        C_帐密[1] = "yabe@2016"
        C_帐密["id"] = 1
        窗口设置大小(窗口获取自我句柄(), 747, 800)
    结束
    如果(!C_调试)
        C_Web = C_YabeWeb & "Member2.php"
        C_网域 = C_YabeWeb
    否则
        C_Web = "http://d.yabeline.tw/Member2.php"
        C_网域 = "http://d.yabeline.tw/"
    结束
    网页清理cookie() 
    网页清理临时目录()  
    线程开启("自动登入", 局_开始)
    init_Main()
    
    //网页跳转("浏览器1", "https://yabeline-ad17d.firebaseapp.com/firebase.html")
    网页跳转("浏览器1", "http://admin.iyabetech.com/firebase?device=" & C_帐密[0])
    变量 局_控件 = 数组("按钮0", "按钮2", "Test")
    变量 局_Value
    遍历(变量 i = 0; i < 数组大小(局_控件); i++)
        数组获取元素(局_控件, i, 局_Value, null)
        控件显示(局_控件[i], 假)
    结束
    checksetstate("不检测App崩溃",filereadini("Config", C_帐密[0] & "_is_check_crash", C_配置路径))
    
    
结束



功能 窗口跟随()
    变量 局_x, 局_y, 局_高
    循环(C_跟随)
        等待(2000)
        //        var 局_跟随窗口 = 窗口查找("逍遙安卓 2.7.2 - MEmu_" & 转字符型(C_帐密["id"]))
        变量 局_跟随窗口 = 窗口查找(字符串格式化("(%s)", C_帐密[0]), "Qt5QWindowIcon")
        如果(局_跟随窗口 == 0)
            局_跟随窗口 = 窗口查找(字符串格式化("%s", C_帐密[0]), "Qt5QWindowIcon")
        结束
        如果(局_跟随窗口 > 0)
            调试输出(局_跟随窗口)
            窗口获取位置(局_跟随窗口, 局_x, 局_y)
            窗口获取大小(局_跟随窗口, null, 局_高)
            窗口设置位置(窗口获取自我句柄(), 局_x, 局_高)
            
        结束
        
        
    结束
结束

功能 窗口定位(参_进程参数)
    变量 局_萤幕数量 = 动态库调用("user32.dll", "int", "GetSystemMetrics", "int", 80)
    如果(局_萤幕数量 == 1)
        返回 假
    结束
    
    如果(参_进程参数[3] <= 3)
        窗口设置位置(窗口获取自我句柄(), (参_进程参数[3] - 1) * 480, 538)
        
    否则 //發圖機的環境
        如果(局_萤幕数量 == 2) //萤幕=2只有编号10的不排序
            如果(参_进程参数[3] >= 14)
                窗口设置位置(窗口获取自我句柄(), (参_进程参数[3] - 14) * 480, 538)
            结束
            如果(参_进程参数[3] <= 4)
                窗口设置位置(窗口获取自我句柄(), (参_进程参数[3] - 1) * 480, 538)
            结束
            如果(参_进程参数[3] <= 10 && (C_帐密[0] != "iyabe10" && C_帐密[0] != "iyabe11" && C_帐密[0] != "iyabe12" && C_帐密[0] != "iyabe13" && C_帐密[0] != "iyabe14" && C_帐密[0] != "iyabe15"))
                窗口设置位置(窗口获取自我句柄(), (参_进程参数[3] - 2) * 480, 538)
                返回 假
            否则
                wlog("窗口定位", "螢幕數量2 10號不排序")
                返回 假
            结束
        结束
        如果(参_进程参数[3] >= 14 && 局_萤幕数量 != 4)
            窗口设置位置(窗口获取自我句柄(), (参_进程参数[3] - 14) * 480, 538)
            返回
        结束
        窗口设置位置(窗口获取自我句柄(), (参_进程参数[3] - 2) * 480, 538)
    结束
    
结束


功能 Sys_错误停止(参_错误)
    文件写配置("Action", C_帐密[0], "停止:" & 参_错误, C_配置路径)
结束

功能 Sys_置讯息(参_讯息, 参_状态 = 假)
    文件写配置("Action", C_帐密[0], 参_讯息, C_配置路径)
    如果(参_状态)
        标签设置文本("状态", 参_讯息)
    结束
结束

功能 自动登入(参_开始 = 假)
    循环(真)
        
        网页跳转("浏览器0", C_YabeWeb & "Lognny2a0b2e3.php")
        变量 start_time = 获取系统时间() 
        循环(!网页加载("浏览器0"))
            等待(100)
            如果(获取系统时间() - start_time > 30*1000)
                Yabe_Client_关闭()
            结束
        结束
        
        等待(3000)
        网页元素输入("浏览器0", C_帐密[0], "name:Line_ID")
        网页元素输入("浏览器0", C_帐密[1], "name:password")
        网页元素点击("浏览器0", "class:btn btn-success")
        遍历(变量 i = 0; i < 30; i++)
            等待(1000)
            如果(字符串查找(网页执行js("浏览器0", "return document.getElementsByTagName('html')[0].innerHTML"), C_帐密[0]) > -1)
                如果(参_开始)
                    
                    启动停止_点击()
                结束
                
                返回 假
            结束
        结束
        
    结束
    
结束

功能 Web_API回报(参_Data) // 参数是一个数组
    变量 局_网址 = "https://yabeline.tw/" & "Stickers_Send.php"
    如果(C_调试)
        局_网址 = "http://d.yabeline.tw/" & "Stickers_Send.php"
    结束
    变量 局_Key = "fsiopljhdrtyw24@541s@d8"
    变量 局_No = 参_Data["No"]
    变量 局_SendBy = C_帐密[0]
    变量 局_数组 = 数组(), 局_Status 
    字符串分割(参_Data["Message"], " - ", 局_数组)
    局_Status = 局_数组[1]
    变量 局_SendData
    
    如果(字符串查找(参_Data["Remark"], "無法發送國外圖") > -1)
        wlog("Web_API回報", "拋訂單到別的帳號" & 字符串格式化("act=asignSender&key=%s&no=%s&sender=%s", 局_Key, 局_No, 文件读配置("Config", "asignDevice", C_配置路径)))
        局_SendData = 字符串格式化("act=asignSender&key=%s&no=%s&sender=%s", 局_Key, 局_No, 文件读配置("Config", "asignDevice", C_配置路径))
    否则
        局_SendData = 字符串格式化("act=report&key=%s&No=%s&Status=%s&Send_By=%s", 局_Key, 局_No, 局_Status, 局_SendBy)
    结束
    
    变量 局_结果 = 字符串替换(http提交请求("post", 局_网址, 局_SendData, "utf-8"), "\r\n", "")
    
    局_结果 = 字符串替换(局_结果, "\n", "")
    局_结果 = 字符串替换(局_结果, "	", "")
    wlog("Web_API回報", "局_Status|" & 局_Status & "," & "局_结果|" & 局_结果)
    wlog("Web_API回報", "回報結果為" & 转字符型(局_结果))
    如果(局_Status == "Success" || 局_Status == "Try_again_Ok")
        变量 局_资料 = 字符串格式化("UserID=%s&No=%s&LineWeb=%s&Message=%s&Acc=%s", 参_Data["ID"], 参_Data["No"], 参_Data["LineWeb"], 局_Status, C_帐密[0])
        线程开启("Web_记录发送状态", 局_资料)
        //Web_记录发送状态(局_资料)
    结束
    网页刷新("浏览器0")
    如果(字符串查找(局_结果, "OK") > -1)
        Sqlite_写订单("")
        等待(3000)
    结束
    如果(字符串查找(局_结果, 局_Status) > -1 || 字符串查找(局_结果, "OK") > -1) // 局_结果 == 局_Status 
        wlog("Web_API回報", "狀態一致")
    否则
        wlog("Web_API回報", "狀態不相符", 假)
    结束
    C_订单发送时间 = null
    time_array = 数组() // 這裡是如果有有回報成功把重置
    返回 字符串查找(局_结果, 局_Status) > -1 || 字符串查找(局_结果, "OK") > -1
结束

功能 Web_记录发送状态(参_字串)
    变量 局_结果 = http提交请求("POST", "https://www.iyabetech.com/Yabe/sendrecord.php", 参_字串, "utf-8")
结束

功能 等待Action_清空()
    遍历(变量 i = 0; i < 25; i++)
        如果(文件读取内容(C_个别资料夹 & "Action.txt") != "")
            等待(1000)
        结束
    结束
结束

功能 Web_推播图片(参_讯息)
    // C1de21f8fff4d4c7a3f0e8246b69db883 异常群组ID
    wlog("Web_推播圖片", "準備推播圖片" & "GoToSThemeRecord," & "C1de21f8fff4d4c7a3f0e8246b69db883", 真)
    如果(字符串查找(参_讯息, "theme") > -1)
        文件覆盖内容(C_个别资料夹 & "Action.txt", "GoToSThemeRecord,C1de21f8fff4d4c7a3f0e8246b69db883", 2)
        等待Action_清空()
    否则如果(字符串查找(参_讯息, "emoji") > -1)
        文件覆盖内容(C_个别资料夹 & "Action.txt", "GoToSEmojiRecord,C1de21f8fff4d4c7a3f0e8246b69db883", 2)
        等待Action_清空()
    否则
        文件覆盖内容(C_个别资料夹 & "Action.txt", "GoToStickerRecord,C1de21f8fff4d4c7a3f0e8246b69db883", 2)
        等待Action_清空()
    结束
    
结束

功能 Web_异常2检测(参_讯息)
    如果(字符串查找(参_讯息, "異常2") == -1)
        wlog("Web_異常2檢測", "無異常2")
        返回
    结束
    Sql_异常2增加(参_讯息["ID"])
    如果(Sql_异常2次数(参_讯息["ID"]) >= 3)
        异常推播(参_讯息["ID"] & "一小内異常2過多")
    结束
结束

功能 大小写转换比对(参_画面ID, 参_客人ID)
    如果(字符串长度(参_画面ID) != 字符串长度(参_客人ID))
        返回 假
    结束
    遍历(变量 i = 0; i < 字符串长度(参_客人ID); i++)
        变量 局_ascii = 字符串格式化("%c", 参_客人ID[i])
        
    结束
    
    返回 真
结束

功能 Xml_检查已发(参_讯息)
    变量 args = "filepath=" & C_个别资料夹 & "XML\\stickerdata.xml" & "&filetype=stkname", t
    变量 stkname = http提交请求("post", "http://127.0.0.1:5000/xml", args, "utf-8")
    wlog("Xml_檢查已發", "檢查訂單的名稱" & stkname)
    遍历(变量 i = 0; i < 5; i++)
        //        var t = strformat("filepath=%s&filetype=%s","C:\\Users\\Lu\\Downloads\\MEmu Download\\march910\\XML\\send_data_" & 转字符型(i)&".xml","sticker")
        如果(字符串查找(参_讯息["LineWeb"], "theme") > -1)
            t = "filepath=" & C_个别资料夹 & "XML\\send_data_" & 转字符型(i) & ".xml" & "&filetype=theme" 
        否则
            t = "filepath=" & C_个别资料夹 & "XML\\send_data_" & 转字符型(i) & ".xml" & "&filetype=sticker" 
        结束
        
        
        变量 data = http提交请求("post", "http://127.0.0.1:5000/xml", t, "utf-8")
        
        变量 局_数组 = json转数组(data, 1)
        遍历(变量 a = 0; a < 数组大小(局_数组); a++)
            
            //            if(局_数组[a]["username"] != 参_讯息["ID"])
            如果(!check_id_same(局_数组[a]["username"], 参_讯息["ID"]))
                继续
            结束
            调试输出(stkname & "," & 局_数组[a]["stkname"])
            如果(局_数组[a]["stkname"] != stkname)
                继续
            结束
            wlog("Xml_检查已发", 局_数组[a]["username"] & "," & 局_数组[a]["stkname"], 真)
            返回 真
        结束
        调试输出(局_数组)
    结束
    返回 假
结束

功能 Web_is异常单(参_讯息)
    变量 局_异常状况 = 参_讯息["Error"]
    返回 局_异常状况 == "封鎖異常" || 局_异常状况 == "加人異常" || 局_异常状况 == "更新異常"
结束

功能 Web_已有此图再检测(&参_讯息)
    如果(字符串查找(参_讯息, "已有此圖") > -1)
        如果(Xml_检查已发(参_讯息))
            如果(Web_is异常单(参_讯息))
                参_讯息["Message"] = "補送成功 - Try_again_Ok"
                
            否则
                参_讯息["Message"] = "已送出 - Success"
            结束
            参_讯息["Remark"] = "新方法判斷已發過此圖"
            //            异常推播(参_讯息["ID"] & "新判斷方法被判斷有發過此圖")
            wlog("Web_已有此圖再檢測", 参_讯息["Message"])
            如果(参_讯息["Message"] != "已送出 - Success" && 参_讯息["Message"] != "補送成功 - Try_again_Ok")
                异常推播(数组转资讯推播整理(参_讯息, "", 真))
                Web_推播图片(参_讯息)
            结束
            
            
            返回 参_讯息
        结束
    结束
    返回 参_讯息
结束

功能 Web_无相似ID(参_讯息) //Stickers_Send.php&act=reset_send&no=訂單編號
    
    如果(字符串查找(参_讯息["Remark"], "無此人") > -1)
        变量 局_网址 = C_YabeWeb & "Stickers_Send.php"
        变量 局_Key = "fsiopljhdrtyw24@541s@d8"
        变量 局_No = 参_讯息["No"]
        变量 局_ID = 参_讯息["ID"]
        //        var 局_SendData = strformat("act=reset_send&key=%s&no=%s", 局_Key, 局_No)
        变量 局_SendData = 字符串格式化("act=reset_receiver&key=%s&line_id=%s", 局_Key, 局_ID)
        变量 局_結果 = http提交请求("post", 局_网址, 局_SendData, "utf-8")
        if(!FireBase_取待加状态())
            FireBase_置加好友状态()
        end
        
        //异常推播(数组转资讯推播整理(参_讯息, "", true))
        //逍遥_关闭模拟器(true)
        wlog("Web_无相似ID", "修改無相似ID 結果" & 局_結果)
        返回 假
    结束
    返回 真
结束

功能 Web_异常清空订单(参_讯息)
    如果(字符串查找(参_讯息["Remark"], "異常訂單清空") > -1)
        wlog("Web_异常清空订单", "異常訂單清空")
        //逍遥_关闭模拟器(真)
        呼叫_Center_关闭()
        返回 假
    结束
    返回 真
结束

功能 Web_回报订单(content, 参_讯息 = "", 参_不确定 = 假)//訊息為空 是中國訂單
    变量 局_回报成功 = 假, 局_清空次数 = 0
    wlog("Web_點選Boss", "準備處理Boss")
    如果(字符串查找(参_讯息, "Line_輸入選擇ID") > -1 || 字符串查找(参_讯息, "無法透過輸入網址進入貼") > -1)
        wlog("Web_回報訂單", "出現「Line_輸入選擇ID」或者無法透過輸入網址進入貼圖")
        逍遥_关闭模拟器(真)
        返回 假
    结束
    Web_已有此图再检测(参_讯息)
    如果(!Web_异常清空订单(参_讯息))
        返回 真
    结束
    如果(!Web_无相似ID(参_讯息))
        呼叫_Center_关闭()
        返回 真
    结束
    if(参_讯息["Message"] == "中國帳號無法接收,取消訂單 - China_Cancel")
        参_讯息["Message"] = "異常Z-其他錯誤 - Manual_Handling26"
        参_讯息["Remark"] = "中國取消改成Z"
        wlog("Web_回报订单","中國取消改成Z", true)
    end
    如果(Web_API回报(参_讯息)) 
        // 如果該筆資料不是-1
        Sqlite_写订单("")
        如果(字符串查找(参_讯息, "發圖機無法加入請人工處理") > -1)
            异常推播(数组转资讯推播整理(参_讯息, "", 真))
        结束
        变量 局_检查发送成功 = 字符串查找(参_讯息, "無法進入聊天室") > -1 || 字符串查找(content, "Double_Cancel_Ok") > -1 || 字符串查找(content, "App查到最近已送") > -1
        Web_异常2检测(参_讯息)
        
        如果((字符串查找(参_讯息, "異常A") > -1 || 局_检查发送成功 || 字符串查找(参_讯息, "狀B") > -1 || 字符串查找(参_讯息, "異常C") > -1 || 字符串查找(参_讯息, "異常Z") > -1) && 字符串查找(参_讯息, "無法發送國外圖") == -1)//&& !C_调试
            如果(字符串查找(参_讯息, "無此人") == -1)
                异常推播(数组转资讯推播整理(参_讯息, "", 真))
            结束
            
            
        结束
        如果(局_检查发送成功)
            Web_推播图片(参_讯息)
        结束
        
        //todo 要等頁面跳轉完
        
        标签设置文本("状态", "")
        文件创建(C_个别资料夹 & "cread.txt")
        变量 局_读订单结果 = Sqlite_读订单()
        循环(局_读订单结果 != "") //如果寫入為空，但是讀出又不為為空
            局_清空次数 = 局_清空次数 + 1
            wlog("Web_點選Boss", "Sqlite清空失敗，準備重試" & 局_读订单结果)
            等待(100)
            如果(!文件删除(C_DB_OrderPath))
                wlog("Web_點選Boss", "刪除C_DB_OrderPathDB 失敗")
            结束
            等待(100)
            如果(局_读订单结果 == "無權限")
                文件创建(C_个别资料夹 & "cread.txt")
            结束
            如果(局_清空次数 >= 5)
                wlog("Web_回報訂單", "清空次數失敗次數過多")
                逍遥_关闭模拟器(假)
                等待(2000)
                退出()
            结束
            init_SqlPath()
            局_读订单结果 = Sqlite_读订单()
        结束
        如果(是否数组(参_讯息))
            Sql写回报(参_讯息["id"], content, 参_讯息["Remark"])
        结束
        返回 真
        
    否则
        wlog("Web_點選Boss", "選擇回報狀態失敗", 假)
    结束
    
    等待(5000)
    返回 假
结束

功能 Web_资料符合(参_国家网址) //订单资料 和 页面资料是否符合
    wlog("Web_資料符合", "準備比對資料是否符合", 假)
    等待(500)
    变量 局_网址 = 字符串替换(网页获取超链接("浏览器0"), "#", "")
    如果(参_国家网址 != 局_网址)
        消息框("應轉向網址:" & 参_国家网址 & "\r\n 當前網址:" & 局_网址, "異常網址")
    结束
    变量 局_贴图网址 = Web_取订单资料_取LineWeb(http_获取源码(局_网址))  //http获取页面源码(局_网址,"utf-8")
    变量 局_数组资料 = 数组(), 局_贴图网址2, 局_资料 = Sqlite_读订单()
    局_数组资料 = 局_资料
    变量 局_ID = 网页元素获取("浏览器0", "value", "tag:INPUT&type:text&index:2&class:form-control")
    // var 局_贴图网址 = 网页元素获取("浏览器0","value","tag:INPUT&index:8") 
    变量 局_异常状况 = 网页元素获取("浏览器0", "text", "tag:FONT&index:2")
    局_异常状况 = 字符串替换(局_异常状况, "【", "")
    局_异常状况 = 字符串替换(局_异常状况, "】", "")
    
    如果(!Web_比对页面id和网址(局_数组资料["ID"], 局_数组资料["LineWeb"]))
        消息框("發圖結果與訂單結果不符合，網頁ID:" & 局_ID & "   訂單ID:" & 局_数组资料["ID"] & "  網頁網址:" & 局_贴图网址 & "   訂單網址:" & 局_数组资料["LineWeb"], C_帐密["0"])
        Sys_错误停止("訂單資料與網頁上不符合")
        返回 假
    结束
    返回 真
结束

功能 重加好友(参_ID) //Stickers_Send.php&act=reset_send&no=訂單編號
    
    
    变量 局_网址 = C_YabeWeb & "Stickers_Send.php"
    变量 局_Key = "fsiopljhdrtyw24@541s@d8"
    变量 局_ID = 参_ID
    变量 局_SendData = 字符串格式化("act=reset_receiver&key=%s&line_id=%s", 局_Key, 局_ID)
    变量 局_結果 = http提交请求("post", 局_网址, 局_SendData, "utf-8")
    if(!FireBase_取待加状态())
        FireBase_置加好友状态()
    end
    
结束



功能 获取页面资讯()
    
    变量 局_贴图网址2
    变量 局_ID = 网页元素获取("浏览器0", "text", "id:para_2")
    变量 局_贴图网址 = 网页元素获取("浏览器0", "value", "tag:INPUT&index:8") //"Name"
    变量 局_异常状况 = 网页元素获取("浏览器0", "text", "tag:FONT&index:2")
    局_异常状况 = 字符串替换(局_异常状况, "【", "")
    局_异常状况 = 字符串替换(局_异常状况, "】", "")
    
    字符串分割(局_贴图网址, "　", 局_贴图网址2)
    BBY_回报贴图资讯(C_帐密[0], 局_ID, 局_贴图网址2[0], C_国家, 局_异常状况, 真)
    
结束

功能 BBY_回报贴图资讯(参_Login, 参_ID, 参_Web, 参_Country, 参_Error, 参_显示 = 假)
    变量 局_资料 = 数组()
    数组追加元素(局_资料, 参_Login, "Login")
    数组追加元素(局_资料, 参_ID, "ID")
    数组追加元素(局_资料, 参_Web, "LineWeb")
    数组追加元素(局_资料, 参_Country, "Country")
    数组追加元素(局_资料, 参_Error, "Error")
    变量 token = "d74c724b4e8b90810f57e466121453d8"
    变量 params = "token=" & token & "&funparams=march911|" & 数组转字符串(局_资料)
    变量 url = "http://get.baibaoyun.com/cloudapi/cloudappapi"
    变量 ret = http提交请求("GET", url & "?" & params, "", "utf-8")
    如果(参_显示)
        消息框(ret)
    结束   
    
结束


功能 按钮0_点击()
    
结束

变量 C_更新检测时间
功能 逍遥_更新Apk()
    如果(!C_更新检测时间 || 时间间隔("s", 当前时间(), C_更新检测时间) < -10)
        C_更新检测时间 = 当前时间()
        变量 局_最新版本号 = 系统获取系统路径(4) & "\\Downloads\\逍遙安卓下載\\Update\\Version.txt"
        变量 局_当前版本号 = C_个别资料夹 & "Version.txt"
        如果(!文件是否存在(局_当前版本号))
            返回 假 //等他寫完資料
        结束
        如果(标签获取文本("状态") == "目前無訂單，抓取新訂單中")
            如果(文件读取内容(局_最新版本号) > 文件读取内容(局_当前版本号))
                xy_卸载apk("MEmu_" & C_帐密["id"], "com.yabe")
                xy_安装apk("MEmu_" & C_帐密["id"], "C:\\Users\\Lu\\Downloads\\MEmu Download\\Update\\YabeRobot.apk")
                等待(2000)
                xy_运行app("MEmu_" & C_帐密["id"], "com.yabe", "com.yabe.UserActivity")
                等待(2000)
            结束
        结束
    结束
    
    
    
结束


功能 按钮1_点击()
    
    
    返回
    变量 s = "var a = document.getElementsByName(\"Line_ID\");return a[1].value;"
    调试输出(网页执行js("浏览器0", s))
    
    
    返回
    获取页面资讯()
结束


功能 按钮2_点击()
    
    
    返回
    //这里添加你要执行的代码
    //traceprint(网页元素选择("浏览器0","補送成功 - Try_again_Ok","tag:SELECT&name:Status&index:0"))
    变量 header = 数组()
    header["Accept"] = "*/*"
    header["User-Agent"] = "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:17.0) Gecko/17.0 Firefox/17.0"
    header["Accept-Language"] = "zh-CN,en-US;q=0.5"
    header["Accept-Encoding"] = "deflate"
    header["Cache-Control"] = "no-cache"
    变量 body = http提交请求("get", "http://140.130.20.180/test.php?age=get", "", "utf-8", header)
    调试输出(body)
    
结束

功能 异常推播(参_讯息, 参_私人 = 假)
    // var 局_讯息 = 窗口获取标题(窗口获取自我句柄()) & "    " & 参_讯息
    变量 局_讯息 = 参_讯息 & "Processr：" & 窗口获取标题(窗口获取自我句柄())
    变量 header = 数组(), body 
    header["Accept"] = "*/*"
    header["User-Agent"] = "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:17.0) Gecko/17.0 Firefox/17.0"
    header["Accept-Language"] = "zh-tw,en-US;q=0.5"
    header["Accept-Encoding"] = "deflate"
    header["Cache-Control"] = "no-cache"
    //变量 body = http提交请求("get","http://ok963963ok.synology.me/Yabe/getError.php?Error="& 局_讯息,"","utf-8",header,"",true,3000)
    //变量 body = http提交请求("get","http://ok963963ok.synology.me/Yabe/PushError.php?Error="& 局_讯息,"","utf-8",header,"",true,3000)
    //变量 body = http提交请求("get","http://www.iyabetech.com/Yabe/PushError.php?Error="& 局_讯息,"","utf-8",header,"",true,3000)
    //变量 body = http提交请求("Post","http://ok963963ok.synology.me/Yabe/PushError.php","Error= " & 局_讯息,"utf-8",header,"",true,3000)
    变量 res = 网页执行js("浏览器0", 字符串格式化("var uri = \"%s\";var t = encodeURI(uri); return t", 局_讯息))
    wlog("異常推播", "準備推播" & 参_讯息, 假)
    如果(参_私人)
        http提交请求("get", "http://www.insightech360.com/Yabe/PushError2.php?Error=" & 局_讯息, "", "utf-8", header, "", 真, 3000)
        返回
    结束
    //var res = 网页执行js("浏览器0","var uri = \"yabeline03 | http://iyabe.tw/Admin_User.php?Line_ID=yabeline03 | 1272686-手指抽蓄 | http://iyabe.tw/Stickers_Search.php?Search=1272686 | line://shop/detail/1272686 | http://iyabe.tw/Admin_Stickers_Edit.php?Number=1272686&Type=1 |  | Country：臺灣 | Status：未接收 | Price：50 | No：1056216 | \";var t = encodeURI(uri); return t")
    如果(!C_调试)
        
        
        //body = http提交请求("post","http://www.insightech360.com/Yabe/PushError.php","Error=" & res,"utf-8",header,"",true,3000)
        调试输出("http://admin.iyabetech.com/push_text/?message=" & res)
        //body = http提交请求("post", "http://yabeline.tw/PushError2.php", strformat("Error=%s", res), "utf-8", header, "", true, 3000)
        body = http提交请求("get", "http://admin.iyabetech.com/push_text/?message=" & res, "", "utf-8", header, "", 真, 3000)
        
        
    否则 // 是調試的話
        //var res = 网页执行js("浏览器0",strformat("var uri = \"%s\";var t = encodeURI(uri); return t",局_讯息))
        //body = http提交请求("post","http://www.insightech360.com/Yabe/PushError2.php",strformat("Error=%s&reciveID=U7eb26c66a1ba386c2d587ccd1d1b6703",res),"utf-8",header,"",true,3000)
        
        body = http提交请求("post", "https://yabeline.tw/PushError2.php", 字符串格式化("Error=%s", res), "utf-8", header, "", 真, 3000)
    结束
    
    
    // 变量 body = http获取页面源码("http://ok963963ok.synology.me/Yabe/PushError.php?Error="& 局_讯息,"utf-8")
    wlog("異常推播", body, 假)
结束


功能 编码转换(str)
    变量 ScriptContorl = 插件("MSScriptControl.ScriptControl")
    ScriptContorl.AllowUI = 真
    ScriptContorl.Language = "JavaScript"//"JavaScript"
    ScriptContorl.AddCode("function add(s1){return encodeURI(s1);}")
    变量  ret = ScriptContorl.Run("add", str)
    ScriptContorl = null
    返回 ret
结束


功能 encodeURL(str)
    变量 ScriptContorl = 插件("MSScriptControl.ScriptControl")
    ScriptContorl.AllowUI = 真
    ScriptContorl.Language = "JavaScript"   
    变量 jsfunction = "function encode(str){return encodeURI(str)}" 
    变量 runcode = "encode(\"" & str & "\");"
    变量 ret = ScriptContorl.Eval(jsfunction & runcode)
    ScriptContorl = null
    返回 ret
结束


功能 Test_点击()
    //这里添加你要执行的代码
    遍历(变量 i = 0; i < 8; i++)
        变量 局_T = 网页元素获取("浏览器0", "text", "tag:SPAN&index:" & 转字符型(i))
        如果(字符串查找(局_T, "貼圖") > -1)
            网页元素点击("浏览器0", "tag:SPAN&index:" & 转字符型(i))
            变量 局_贴图 = 字符串截取(局_T, 字符串查找(局_T, "貼圖") - 2, 字符串查找(局_T, "貼圖"))
            C_国家 = 局_贴图
            调试输出(C_国家)
            跳出
        结束
        
    结束
结束


功能 IdSelect_选择改变()
    编辑框设置文本("ID", 下拉框获取文本("IdSelect"))
结束


功能 getCookie(参_帐号, 参_密码)
    变量 token = "e0efc91651d08055ebc578d8359f9d0c"
    变量 params = "token=" & token & "&funparams=" & url编码(数组转字符串(数组("0" = 参_帐号, "1" = 参_密码)))
    变量 url = "http://get.baibaoyun.com/cloudapi/cloudappapi"
    变量 ret = http提交请求("GET", url & "?" & params, "", "utf-8", null, "", 真, 3000)
    调试输出(ret)
    返回 ret
结束

功能 BBY_TEST_点击()
    文件覆盖内容(C_Noxshare & C_帐密[0] & "\\Vpn.txt", "Expressvpn")
    文件写配置("VPN", C_帐密[0], "∞", C_配置路径)
    // threadbegin("yes_is已处理","")
    //主线程 = threadbegin("主线程","")
    //    Web_取待送国家()
    //    return
    //设置剪切板(http获取页面源码("http://deve.iyabe.tw/Friend_Stickers_Send.php?Country=ja","utf-8"))
    //messagebox(Web_取待送资料())
    变量 局_资料 = 数组()
    数组追加元素(局_资料, C_帐密[0], "Login")
    数组追加元素(局_资料, 编辑框获取文本("ID"), "ID")
    数组追加元素(局_资料, 编辑框获取文本("Web"), "LineWeb")
    数组追加元素(局_资料, 编辑框获取文本("Country"), "Country")
    //arraypush(局_资料,C_国家英文[参_国家],"Country")
    数组追加元素(局_资料, 编辑框获取文本("Error"), "Error")//0 無異常 1封鎖異常 2更新異常
    数组追加元素(局_资料, "未接收", "Status")
    数组追加元素(局_资料, 编辑框获取文本("Price"), "Price")
    数组追加元素(局_资料, "", "Message")
    Web_取VPN权限(编辑框获取文本("Country"))
    Sqlite_写订单(局_资料)
    //messagebox(BBY_回报贴图资讯(C_帐密[0],editgettext("ID"),editgettext("Web"),editgettext("Country"),editgettext("Error"),true)) //仿造訂單
结束


功能 test()
    变量 局_Code = 文件读取内容("C:\\Users\\Lu\\Desktop\\test1.txt")
    变量 局_ID = 正则子表达式匹配(局_Code, "type=\"text\" name=\"Line_ID\" id=\"Line_ID\" value=\"([\\sa-zA-Z0-9\\._-]+)", 假, 真, 真)
    调试输出(局_ID)
结束

功能 set_robot_run_state(参_state)
    http提交请求("get", "http://127.0.0.1:5000/robot/state/set?device=" &C_帐密[0] & "&state="& 参_state, "")
结束

功能 启动停止_点击()
    如果(按钮获取文本("启动停止") == "啟動")
        //set_robot_run_state(1)
        按钮设置文本("启动停止", "停止")
        wlog("啟動停止_點擊", "啟動")
        文件覆盖内容(C_运作路径, "Run")
        主线程 = 线程开启("主线程", "")
        监测线程 = 线程开启("AppCarshCheckThread", "")
        
        //窗口跟随线程 = threadbegin("窗口跟随", "")
    否则
        //set_robot_run_state(0)
        文件覆盖内容(C_运作路径, "Stop") //让模拟器App可以停止
        Sys_置讯息("停止", 真)
        wlog("啟動停止_點擊", "停止")
        文件删除(C_个别资料夹 & "發圖中.txt")
        按钮设置文本("启动停止", "啟動")
        线程关闭(主线程, 1)
        线程关闭(监测线程, 1)
        线程关闭(窗口跟随线程, 1)
        Web_置VPN解锁()
    结束
    
结束


//点击关闭_执行操作
功能 Yabe_Client_关闭()
    如果(按钮获取文本("启动停止") == "停止")
        启动停止_点击()
    结束
    C_跟随 = 假
    线程关闭(主线程, 1)
    线程关闭(监测线程, 1)
    线程关闭(bmpToGifThread, 1)
    线程关闭(窗口跟随线程, 1)
    
    退出()
结束



功能 Yabe_Client_销毁()
    //这里添加你要执行的代码
结束


功能 批量下单_点击()
    如果(编辑框获取文本("ID") == "")
        消息框("請填寫ID", "")
        返回 假
    结束
    变量 局_路径 = 文件对话框(1, "*.txt")
    
    如果(局_路径 != "")
        线程开启("AutoReadList", 局_路径)
    结束
    
结束



功能 http_获取源码(参_网址, 参_源码 = "")
    Global_源码开关 = 真
    变量 局_返回, 局_响应, header = 数组("Accept" = "*/*", "User-Agent"="Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1 Edg/114.0.0.0", "passme"="JWE7^hjFAv#9J2")
    如果(参_源码 == "")
        //局_返回 = http获取页面源码(参_网址, "utf-8")
        局_返回 = http提交请求扩展("get", 参_网址, 参_源码, "", 局_响应, header, "utf-8")
    否则
        局_返回 = http提交请求扩展("get", 参_网址, 参_源码, "", 局_响应, header, "utf-8")
    结束
    
    Global_源码开关 = 假
    返回 局_返回
结束


//消息路由功能
功能 Yabe_Client_消息路由(句柄, 消息, w参数, l参数, 时间, x坐标, y坐标)
    如果(控件获取句柄("贴图数量") == 句柄 && 消息 == 256)
        如果(w参数 == 13)
            文件覆盖内容(C_个别资料夹 & "Action.txt", "GoToStickerRecord," & 转字符型(编辑框获取文本("贴图数量")), 2)
        结束
        
    结束
    返回 假
结束


//消息过程功能
功能 Yabe_Client_消息过程(消息, w参数, l参数)
    如果(w参数 == 120 && l参数 == 120)
        如果(按钮获取文本("启动停止") == "停止")
            启动停止_点击()
        结束
    结束
    如果(w参数 == 123 && l参数 == 123)
        调试输出("123")
        如果(按钮获取文本("启动停止") == "停止")
            启动停止_点击()
            等待(100, 假)
        结束
        退出()
    结束
    如果(w参数 == 120 && l参数 == 121)
        如果(按钮获取文本("启动停止") == "停止")
            启动停止_点击()
            等待(100, 假)
            退出()
        结束
    结束
    如果(w参数 == 5000 && l参数 == 5000)
        如果(标签获取文本("状态") == "目前無訂單，抓取新訂單中")
            C_订单标志 = 真
        结束
    结束
结束



功能 getID_点击()
    
    变量 a = 数组(), id
    遍历(变量 i = 2; i < 字符串分割(文件读取内容("a:\\id.txt"), "\r\n", a); i++)
        如果(a == "")
            跳出
        结束
        id = id & a[i] & ","
        
    结束
    调试输出(数组大小(a))
    设置剪切板(id)
结束

功能 呼叫_Center_关闭()
    if(Firebase_取重启状态())
        Firebase_重置重启状态()
    end
    wlog("呼叫_Center_關閉", "呼叫Center 關閉")
    窗口发送消息(窗口查找("YabeCenter"), 10000, 窗口获取自我句柄(), 123)
结束

功能 开主题_点击()
    //Web_推播图片("theme")
    //    窗口发送消息(窗口查找("YabeCenter"),10000,窗口获取自我句柄(),123)
    //    threadbegin("Yabe_Client_关闭","")
    //    openprocess("C:\\move.bat")
    
    文件覆盖内容(C_个别资料夹 & "Action.txt", "GoToSThemeRecord", 2)
    
结束


功能 按钮3_点击()
    变量 局_资讯分割
    变量 s = "Login：yabeline03 | ID：77888 | LineWeb：line://shop/theme/detail?id=6aba24e7-aba4-4095-8e4e-53f31541d0f8 | Country：臺灣 | Error： | Status：已處理 | Price：50 | Message：異常C-代幣價格錯誤 - Manual_Handling3 | No： | Remark： |"
    字符串分割(s, " | ", 局_资讯分割)
    变量 aa = Sqlite_内部资讯分割(局_资讯分割)
    变量 bb = 字符串转数组(aa)
    异常推播(数组转资讯推播整理(bb, "", 真))
    调试输出("")
    
    //FireBase_置加好友状态()
    
结束


功能 删除已发_点击()
    变量 t = 缩网址("https://yabeline.tw/Admin_Stickers_Edit.php?Number=1634716&Type=1")
    命令(t, 假)
    控件打开子窗口("刪除已發")
    
结束


功能 按钮4_点击()
    
    
结束


功能 刷_点击()
    //    filewriteex(C_个别资料夹 & "Credit.txt",checkgetstate("刷"))
    变量 局_开关 = 复选框获取状态("刷")
    调试输出(局_开关)
    变量 局_窗口 = 窗口查找("YabeCenter")
    窗口发送消息(局_窗口, 10001, C_帐密["id"], !局_开关)
    如果(局_开关)
        如果(按钮获取文本("启动停止") == "停止") // 如果刷卡状态，且是运行中就关闭
            
            启动停止_点击()
        结束
    否则 // 取消刷卡状态
        如果(按钮获取文本("启动停止") == "啟動") // 如果非刷卡状态，且是运行中就关闭
            http提交请求("get", "http://127.0.0.1:5000/swipe_finished?model=" & C_帐密[0], "")
            启动停止_点击()
        结束
    结束
    
结束



变量 time_array = 数组()
变量 times = 0

功能 关_点击()
    呼叫_Center_关闭()
    test_block()
    返回
    逍遥_关闭模拟器()
结束

变量 C_超时时间 = null

功能 isascii(s, index)
    
    返回 字符串返回字符(s, index) >= 32 && 字符串返回字符(s, index) <= 126
结束

功能 check_id_same(orgin, other)
    如果(字符串长度(orgin) != 字符串长度(other))
        返回 假
    结束
    遍历(变量 i = 0; i < 字符串长度(orgin); i++)
        
        如果(字符串截取(orgin, i, i + 1) == 字符串截取(other, i, i + 1)) 
            继续
        否则如果(isascii(orgin, i) && isascii(other, i) && (字符串返回字符(字符串转小写(字符串截取(orgin, i, i + 1)), 0) == 字符串转小写(字符串返回字符(字符串截取(other, i, i + 1), 0)))) // 都是ascii 转小写在比较
            继续
            
        结束
        变量 now_str1 = 字符串截取(orgin, i, i + 1)
        变量 now_str2 = 字符串截取(other, i, i + 1)
        如果(now_str1 == now_str2)
            继续
        结束
        now_str1 = 字符串转小写(now_str1)
        now_str2 = 字符串转小写(now_str2)
        如果(now_str1 == now_str2)
            继续
        结束
        如果(字符串返回字符(now_str1, 0) == 字符串返回字符(now_str2, 0))
            继续
        结束
        调试输出(字符串截取(orgin, i, i + 1) & "," & 字符串返回字符(other, i))
        返回 假
        
    结束
    返回 真
结束

功能 超_点击()
    呼叫_Center_关闭()
    变量 局_Path = C_个别资料夹 & "Running.txt"
    变量 局_上次运行时间 = 文件读取内容(局_Path)
    C_App运行时间 = 时间间隔("s", 局_上次运行时间, 当前时间())
    如果(!C_App运行时间 || C_App运行时间 == "")
        如果(!C_超时时间)
            C_超时时间 = 当前时间()
        结束
        wlog("超", "為空時間" & 时间间隔("s", 当前时间(), C_超时时间))
        如果(时间间隔("s", 当前时间(), C_超时时间) < -60)
            xy_关闭模拟器(C_帐密[0])
        结束
        
    否则
        C_超时时间 = null
    结束
    wlog("超", 转字符型(C_App运行时间))
结束


功能 加好友_点击()
    变量 path = C_个别资料夹 & "是否加好友.txt"
    如果(!文件是否存在(path))
        变量 handle = 文件创建(path)
        文件关闭(handle)
    结束
    调试输出(复选框获取状态("加好友"))
    http提交请求("GET", "http://127.0.0.1:5000/robot/add/set?device=" & C_帐密[0] & "&on=" & 复选框获取状态("加好友"),null,"gb3212")
    
    变量 h2 = 文件打开(path)
    文件写入字符(h2, 转字符型(复选框获取状态("加好友")))
结束


功能 展_点击()
    
    
    var 宽,高
    窗口获取大小(窗口获取自我句柄(), 宽, 高)
    if(宽 > 550)
        窗口设置大小(窗口获取自我句柄(), 490, 485)
    else
        窗口设置大小(窗口获取自我句柄(), 768, 497)
    end
    
结束


功能 丟加好友_点击()
    var 丟加好友 = checkgetstate("丟加好友")
    filewriteini("Config", C_帐密[0] & "reset_friend",丟加好友, C_配置路径)
结束


功能 加好友选项_选择改变()
    var Add_Friend_option = combogetcursel("加好友选项")
    filewriteini("Config", C_帐密[0] & "Add_Friend_option",Add_Friend_option, C_配置路径)
    var option_text = combogettext("加好友选项")
    var all_path = C_个别资料夹 & "加好友國外all.txt"
    var N_path = C_个别资料夹 & "加好友國外N.txt"
    if(option_text == "發全部")
        
        if(!fileexist(all_path))
            fileclose(filecreate(all_path))
        end
    elseif(option_text == "發臺灣")
        if(!fileexist(N_path))
            fileclose(filecreate(N_path))
        end
        filedelete(all_path)
        
    elseif(option_text == "發國外")
        
        filedelete(all_path)
        filedelete(N_path)
    end
    
结束


功能 不检测App崩溃_点击()
    var is_check_crash = confirmationbox("要記錄不崩潰嗎","提示",2,true)
    if(is_check_crash == 7)
        filewriteini("Config", C_帐密[0] & "_is_check_crash",checkgetstate("不检测App崩溃"), C_配置路径)
    end
结束


功能 emoji_z_点击()
    var 丟加好友 = checkgetstate("emoji_z")
    filewriteini("Config", C_帐密[0] & "emoji_z",丟加好友, C_配置路径)

结束
