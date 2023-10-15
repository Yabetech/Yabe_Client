var FireBase_时间 = ""

function flask_set_vpntype(type_str)
    http提交请求("get","http://127.0.0.1:5000/vpn/set?device=" &  C_帐密[0] & "&type=" & type_str,"")
end

function Web_取VPN权限(参_国家)
    wlog("Web_取VPN權限", "準備獲取Vpn權限", false)
    if(参_国家 == "日本" && filereadini("openvpn", "日本", 系统获取进程路径() & "Cfg.ini") || 参_国家 == "印尼" && filereadini("openvpn", "印尼", 系统获取进程路径() & "Cfg.ini"))
        filewriteex(C_Noxshare & C_帐密[0] & "\\Vpn.txt", "Openvpn")
        filewriteini("VPN", C_帐密[0], "∞", C_配置路径)
        flask_set_vpntype("Openvpn")
        return true
    end
    flask_set_vpntype("Expressvpn")
    filewriteex(C_Noxshare & C_帐密[0] & "\\Vpn.txt", "Expressvpn")
    变量 header = 数组(), 局_结果
    //    if(C_帐密[0] == "yabeline03")
    //        return true
    //    end
    header["Accept"] = "*/*"
    header["User-Agent"] = "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:17.0) Gecko/17.0 Firefox/17.0"
    header["Accept-Language"] = "zh-CN,en-US;q=0.5"
    header["Accept-Encoding"] = "deflate"
    header["Cache-Control"] = "no-cache"
    var 局_记录时间 = 获取系统时间()
    //局_结果 = http提交请求("get", "http://ok963963ok.myqnapcloud.com/Yabe/YabeVpn2.php?Device=" & C_帐密[0] & "&OnOff=True", "", "utf-8", header, "", true, 3000)
    局_结果 = http提交请求("get", "http://www.iyabetech.com/Yabe/YabeVpn2.php?Device=" & C_帐密[0] & "&OnOff=True", "", "utf-8", header, "", true, 3000)
    if(获取系统时间() - 局_记录时间 > 5000)
        wlog("Web_取VPN權限", "獲取權限超過5秒，可能超時", false)
    end
    wlog("Web_取VPN權限", "獲取Vpn權限結果: " & 局_结果, false)
    //traceprint("http://ok963963ok.synology.me/Yabe/YabeVpn.php?Device="& C_帐密[0] &"&OnOff=True")
    if(strfind(局_结果, "Fail") > -1)
        filewriteini("VPN", C_帐密[0], "", C_配置路径)
        wlog("Web_取VPN權限", "系統不給予VPN權限", true)
        return false
    else
        staticsettext("状态", "")//取得權限就清空狀態顯示
        wlog("Web_取VPN權限", "系統給予VPN權限", true)
        filewriteini("VPN", C_帐密[0], "√", C_配置路径)
        return true
    end
    
end

function Web_置VPN解锁()
    变量 header = 数组(), 局_结果
    header["Accept"] = "*/*"
    header["User-Agent"] = "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:17.0) Gecko/17.0 Firefox/17.0"
    header["Accept-Language"] = "zh-CN,en-US;q=0.5"
    header["Accept-Encoding"] = "deflate"
    header["Cache-Control"] = "no-cache"
    
    //局_结果 = http提交请求("get", "http://ok963963ok.myqnapcloud.com/Yabe/YabeVpn2.php?Device=" & C_帐密[0] & "&OnOff=false", "", "utf-8", header, "", true, 3000)
    局_结果 = http提交请求("get", "http://www.iyabetech.com/Yabe/YabeVpn2.php?Device=" & C_帐密[0] & "&OnOff=false", "", "utf-8", header, "", true, 3000)
    filewriteini("VPN", C_帐密[0], "", C_配置路径)
    
    if(strfind(局_结果, "Fail") > -1)
        return false
    else
        return true
    end
    
end



function Web_取订单资料(参_国家)
    var 局_贴图权限
    wlog("Web_取訂單資料", "準備獲取" & 参_国家, false)
    if(是否已处理() || 是否发图中())
        return false
    end
    if(C_App运行时间 > 10)
        wlog("Web_取訂單資料", "模擬器可能啟動中...等待五秒")
        sleep(1500)
    end
    
    if(参_国家 != "臺灣" && 参_国家 != "") // 不等於   臺灣必須先取得VPN權限
        
        局_贴图权限 = Web_取VPN权限(参_国家)
        
        
        if(局_贴图权限)// 有權限直接取國外的
            wlog("Web_取訂單資料", "取得權限準備取" & 参_国家, false)
            return Web_取订单资料_单纯取资料(参_国家)
        end
        while(!局_贴图权限)
            
            if(局_贴图权限)
                wlog("Web_取訂單資料", "循環取得權限準備取" & 参_国家, false)
                return Web_取订单资料_单纯取资料(参_国家)
            else
                if(arrayfindkey(C_待送国家, "臺灣") > -1)
                    staticsettext("状态", "有國外訂單，但無VPN權限，改發台灣單")
                    sleep(3000)
                    return Web_取订单资料_单纯取资料("臺灣")
                else
                    Sys_置讯息(参_国家 & "有國外訂單，等待VPN權限", true)
                    if(strfind(Web_取待送国家("Web_取訂單資料"), "臺灣") > -1)
                        staticsettext("状态", "有國外訂單，但無VPN權限，改發台灣單")
                        wlog("Web_取訂單資料", "有國外訂單，但無VPN權限，改發台灣單")
                        sleep(3000)
                        return Web_取订单资料_单纯取资料("臺灣")
                    end
                    等待时间(filereadini("CenterConfig", "VPNdelay", C_配置路径) * 1000, "等待")
                    
                    局_贴图权限 = Web_取VPN权限(参_国家)
                    
                end          
            end
        end
    end
    if(参_国家 == "")
        return false
    end
    return Web_取订单资料_单纯取资料(参_国家) //取臺灣的
end

function Web_除错资料异常(参_ID, 参_网址, 参_发图中文件存在)
    if(参_ID == null)
        wlog("Web_除錯資料異常", 参_ID & "為null")
    end
    if(参_网址 == null)
        wlog("Web_除錯資料異常", 参_网址 & "網址為null")
    end
    if(参_发图中文件存在)
        wlog("Web_除錯資料異常", 参_发图中文件存在 & "發圖中.txt存在")
    end
end

function test_block()
    // 檢測是否卡單
    var value,key
    arraypush(time_array, 获取系统时间())
    times = 0
    var start = (获取系统时间() - 80 * 1000)
    var now = 获取系统时间()
    for(var i = 0; i < arraysize(time_array); i++)
        arraygetat(time_array, i, value,key)
        if(start < value && value < now)
            times = times + 1
        elseif(value < start)
            arraydeletekey(time_array, key)
            
        end
        //traceprint()
    end
    wlog("test_block","疑似卡單檢測 次數"& 转字符型(times))
    if(times >= 15)
        wlog("測試","準備關閉疑似卡單")
        设置托盘(C_帐密[0])
        设置托盘气泡("卡單處理中")
        xy_关闭模拟器(C_帐密[0])
        呼叫_Center_关闭()
        return true
    end
    
    return false
end

function Web_取订单资料_单纯取资料(参_国家)
    var 局_ID, 局_Code, 局_No, 局_记录时间 = 获取系统时间()
    wlog("Web_取訂單資料_單純取資料", "準備獲取訂單資訊", false)
    局_Code = http_获取源码(Cw_国家网址[参_国家]) //页面原始码 http获取页面源码(Cw_国家网址[参_国家],"utf-8") 
    wlog("Web_取訂單資料_單純取資料", "獲取訂單資訊結束", false)
    //Web_判断待加好友(局_Code)
    var 局_10代币编号 = array("4105", "4105", "4892", "4508", "5356", "4055", "4928", "3722", "5111", "5170", "3904")
    if(局_Code != null)
        webgo("浏览器0", Cw_国家网址[参_国家])
        if(C_调试)
            局_ID = 正则子表达式匹配(局_Code, "<p id=\"para\" style=\"padding:5px 0px 0px 0px;\">([a-zA-Z0-9\\._-]+)", false, true, true)
        else
            局_ID = 正则子表达式匹配(局_Code, "<p id=\"para_2\" style=\"padding:5px 0px 0px 0px;\">([\\x{4e00}-\\x{9fa5}a-zA-Z0-9\\._-]+)", false, true, true)
            if(arraysize(局_ID) == 0)
                局_ID = 正则子表达式匹配(局_Code, "type=\"text\" name=\"Line_ID\" id=\"Line_ID\" value=\"([\\sa-zA-Z0-9\\._-]+)", false, true, true)
            end
            
            
        end
        var 局_LineWeb = Web_取订单资料_取LineWeb(局_Code)
        var 局_DateTime = 正则表达式匹配(局_Code, "(\\d{4}-\\d{2}-\\d{2}) (\\d{2}:\\d{2}:\\d{2})", true, true)
        var 局_Error = 正则子表达式匹配(局_Code, "<font color=\"red\">【(\\S{0,4})", false, false)
        var 局_价格 = 正则子表达式匹配(局_Code, "<p id=\"Price\" style=\"padding:5px 0px 0px 0px;\">\\s+(\\d+)\\s+", true, true)
        var 局_编号 = 正则子表达式匹配(局_LineWeb, "(\\d+)")
        
        局_No = 正则子表达式匹配(局_Code, "id=\"No\" value=\"(\\d+)", true, true)
        var 局_贴图名称 = Web_取订单资料_单纯取资料_贴图名称处理(局_Code)
        var 局_资料 = array()
        wlog("Web_取訂單資料_單純取資料", "獲取詳細資料完成", false)
        if(checkgetstate("丟加好友"))
            wlog("", "加好友")
            重加好友(局_ID[0])
            呼叫_Center_关闭()
            return false
        end
        if(局_ID[0] != null && 局_LineWeb != null && (!fileexist(C_个别资料夹 & "發圖中.txt") )) //(strfind(aa,"已處理") == -1 || aa == "" ) 確保不是再發圖得狀態
            
            arraypush(局_资料, strreplace(局_ID[0], " ", ""), "ID")
            arraypush(局_资料, "", "Message")
            arraypush(局_资料, strreplace(局_贴图名称, "'", ""), "StkName")
            arraypush(局_资料, 局_LineWeb, "LineWeb")
            arraypush(局_资料, 参_国家, "Country")
            arraypush(局_资料, "未接收", "Status")
            //arraypush(局_资料,C_国家英文[参_国家],"Country")
            arraypush(局_资料, 局_Error[0], "Error")//0 無異常 1封鎖異常 2更新異常
            arraypush(局_资料, 局_价格["0"], "Price")
            arraypush(局_资料, 局_No["0"], "No")
            arraypush(局_资料, "", "ReplyContent")
            arraypush(局_资料,局_DateTime["0"], "DateTime")
            Web_取订单资料_单纯取资料_自动回复侦测(局_资料)
            if(yes_is已处理_检测已有此图(局_资料))
                return false
            end//检测App是否已經發過此圖，可能是上一个回报失败
            wlog("Web_取訂單資料_單純取資料", "訂單資訊:" & arraytostring(局_资料), false)
            Sqlite_写订单(局_资料)
            editsettext("订单资料2", " " & 资讯断行(数组转资讯(局_资料, "Status")))
            wlog("Web_取訂單資料_單純取資料", "已發送資料給APP端發圖")
            Sys_置讯息("已發送資料給APP端發圖", true)
            test_block()
            wlog("沒發圖中的資訊", arraytostring(局_资料))
            Sql写订单(局_ID[0], 局_资料)
            C_订单发送时间 = 当前时间()
            if(checkgetstate("emoji_z") && strfind(局_资料["LineWeb"], "emoji") > -1)
                局_资料["Message"] = "異常Z-其他錯誤 - Manual_Handling26"
                Web_回报订单(局_资料["Message"], 局_资料)
                return false
            end
            Sqlite_写订单(局_资料)
            sleep(2000)
            return true
        else
            wlog("Web_取訂單資料_單純取資料", "無法獲取資料，資料異常")
            Web_除错资料异常(局_ID[0], 局_LineWeb, !fileexist(C_个别资料夹 & "發圖中.txt"))
        end
        if(fileexist(C_个别资料夹 & "發圖中.txt"))
            wlog("Web_取訂單資料_單純取資料", "異常發圖狀態")
        end
    end
    
    if(局_Code == null)
        //wlog("Web_取訂單資料_單純取資料","網頁原始碼為" & 局_Code,false)
        //threadbegin("Yabe_Client_关闭","")
        if(C_Debug_取资料时间 != null)
            if(时间间隔("s", C_Debug_取资料时间, 当前时间()) < 3 && 时间间隔("s", C_Debug_取资料时间, 当前时间()) > 0)
                wlog("Web_取訂單資料_單純取資料", "無法取得資料準備重開")
                呼叫_Center_关闭()
                //退出()
            end
        end
        C_Debug_取资料时间 = 当前时间()
        
    end
    if(!局_Code && 获取系统时间() - 局_记录时间 > 25000)
        wlog("Web_取訂單資料_單純取資料", "獲取訂單資料超時25秒")
    end
    var 局_待发国家 = Web_取待送国家()
    if(strfind(局_待发国家, 参_国家) > -1) //這邊可能是原本應該沒資料了，可是又找到該國家資料
        
        //卡死重开检测()
        
    end
    wlog("Web_取訂單資料_單純取資料", "除錯斷點", false)
    editsettext("订单资料2", "")
    Firebase_置发送状态()
    Sys_置讯息("目前無訂單，抓取新訂單中")
    staticsettext("等待", "")
    Web_置VPN解锁()
    return false
end

//把Code 丢进来后处理所有贴图名称
function Web_取订单资料_单纯取资料_贴图名称处理(参_网页码)
    var 局_结果 = 正则子表达式匹配(参_网页码, "</span>(.+)", true, true)
    
    for(var i = 0; i < arraysize(局_结果); i++)
        if(strfind(局_结果[i], "/a") == -1 && strfind(局_结果[i], "/div") == -1)
            var 局_result = strreplace(局_结果[i], " ", "")
            局_result = strreplace(局_result, "&", "")
            局_result = strreplace(局_result, ";", "")
            局_result = strreplace(局_result, "\"", "")
            局_result = strreplace(局_result, "#39", "")
            return 局_result
        end
    end
    
    return ""
end

function Web_取订单资料_单纯取资料_自动回复侦测(&参_资料数组)
    var 局_ID路径 = C_Noxshare & "ReplyID.txt"
    var 局_Number路径 = C_Noxshare & "ReplyNumber.txt"
    var 局_讯息路径 = C_Noxshare & "ReplyContent.txt"
    var 局_讯息 = "", 局_ID数组, 局_ID, 局_Number, 局_序号回复 = false
    if(!fileexist(局_ID路径) || !fileexist(局_Number路径))
        return false
    end
    局_ID = filereadex(局_ID路径)
    局_Number = filereadex(局_Number路径)
    if(局_ID == "" || 局_Number == "" || strfind(局_ID, 参_资料数组["ID"]) == -1)
        return false
    end
    var 局_序号数组 = 取分割(局_Number, ",")
    for(var i = 0; i < arraysize(局_序号数组); i++) //查找该张订单是否是需要回复的网址
        if(strfind(参_资料数组["LineWeb"], 局_序号数组[i]) > -1)
            局_序号回复 = true
            break
        end
    end
    if(!局_序号回复) // 如果贴图网址不是要回复的直接返回
        return false
    end
    局_ID数组 = 取分割(局_ID, "\r\n")
    if(数组值查找(局_ID数组, 参_资料数组["ID"]) == -1) //如果没这ID返回false
        return false
    end
    局_讯息 = filereadex(局_讯息路径)
    if(局_讯息 != "")
        参_资料数组["ReplyContent"] = 局_讯息
    else
        参_资料数组["ReplyContent"] = "感謝您對Yabe的支持,這是廠商隨機贈送的貼圖，祝您有愉快的一天^^"
    end
    
end

function Web_中国回报(参_国家)
    if(参_国家 == "中國")
        wlog("Web_中國回報", "中國訂單直接回報")
        webgo("浏览器0", Cw_国家网址[参_国家])
        sleep(1000)
        for(var i = 0; i < 15; i++)
            staticsettext("状态", "發圖結果回報網站")
            wlog("Web_中國回報", "進入回第" & i & "次", false)
            var s = "var a = $(\"[id=Name]\"); return a[1].value;"
            if(网页执行js("浏览器0", s) != "")
                break
            end
            sleep(1000)
        end
        Web_回报订单("異常9-中國封鎖LINE - Error9") //写回报后会把Order.txt净空
        return true
    end
    return false
end

function Web_取订单资料_取LineWeb(参_Code)
    
    //    if(strfind(参_Code,"https://line.me/S/emoji/") > -1)
    //        var 局_Web数组 = 正则表达式匹配(参_Code,"line.me/S/emoji/\\S+",false,true)
    //        var result = strreplace(局_Web数组["0"],"\"","")
    //        result = strreplace(result,">","")
    //        return "https://" & result
    //    end
    var 局_Web数组 = 正则表达式匹配(参_Code, "line://shop/\\S+", false, true)
    for(var i = 0; i < arraysize(局_Web数组); i++)
        var str = 局_Web数组[i]
        if(strfind(str, "1276714") == -1 && strfind(str, "　") == -1)
            str = strreplace(str, "\"", "")
            str = strreplace(str, ">", "")
            str = strreplace(str, "'", "")
            traceprint(str)
            return str
        end
    end
    return null
end

function Web_取待送国家(参_讯息 = "") //取有多少資料可以送
    //    if(G_上次取订单的时间 == null)
    //        G_上次取订单的时间 = timenow()
    //        sleep(2)
    //    else
    //        wlog("Web_取待送國家","距離上次取訂單間格為" & 时间间隔("s",G_上次取订单的时间,timenow()) & "秒")
    //        if(时间间隔("s",G_上次取订单的时间,timenow())<5)
    //            wlog("Web_取待送國家","異常獲取訂單狀態準備退出")
    //            sleep(5000)
    //            Yabe_Client_关闭()
    //        end
    //        G_上次取订单的时间 = timenow()
    //    end
    var date_array = array()
    var 局_记录时间 = strsplit(当前时间(), " ", date_array)
    var 局_ETime = 字符串格式化("%s %s:%s:00", date_array[0], "03", "50")
    var 局_STime = 字符串格式化("%s %s:%s:00", date_array[0], "04", "30")
    局_ETime = strreplace(局_ETime, "-", "/")
    局_STime = strreplace(局_STime, "-", "/")
    //    traceprint(时间间隔("n",局_ETime,当前时间()))
    if(!checkgetstate("無視維修"))
        while(时间间隔("n", 局_ETime, 当前时间()) >= 0 && 时间间隔("n", 局_STime, 当前时间()) < 0)
            sleep(1000 * 10)
            if(时间间隔("n", 局_记录时间, 当前时间()) >= 30)
                局_记录时间 = 当前时间()
                wlog("Web_取待送國家","網站維修時間,禁止發圖")
                
            end
            
        end
    end
    //假设时间大于结束时间小于开始时间就循环
    
    wlog("Web_取待送國家", "呼叫函數為" & 参_讯息, false)
    wlog("Web_取待送國家", "準備獲取待送國家", false)
    var 局_页面 = http_获取源码(C_YabeWeb & "Member2.php") //http获取页面源码(C_YabeWeb & "Member2.php","utf-8")
    
    wlog("Web_取待送國家", "獲取待送國家完成", false)
    Web_判断待加好友(局_页面)
    if(strfind(局_页面, "發完") > -1 || fileexist(C_个别资料夹 & "發圖中.txt")) // 已經發完網站無訂單，
        Web_取待送国家_是否发完(局_页面)
        return ""
    elseif(strfind(局_页面, "登入會員") > -1 || strfind(局_页面, "404") > -1)// 已经被登出了
        //网页跳转("",C_YabeWeb & "Member2.php")
        wlog("", "登入會員" & cstring(strfind(局_页面, "登入會員")))
        wlog("Web_取待送國家", "網站異常登出,或者瞬斷404")
        //异常推播("網站異常登出,或者瞬斷404")
        Sys_置讯息(C_帐密[0] & "網站異常登出,或者瞬斷404")
        
        呼叫_Center_关闭()
        return ""
    elseif(局_页面 == null)
        wlog("Web_取待送國家", "目前無待送國家")
        return ""
    end
    var 局_数量 = 正则子表达式匹配(局_页面, "<td><span class=\"markText13 \">(\\d+)", false, true)
    var 局_国家 = 正则子表达式匹配(局_页面, "<td><span class=\"markText13 markRed\">【(\\W{6})", false, true)
    var 局_时间 = 正则子表达式匹配(局_页面, "(\\d{2}:\\d{2})", false, true)
    Web_取待送国家_整理国家(局_国家)
    var 局_讯息 = "", 局_待发数量 = 0
    arrayclear(C_待送国家)
    for(var i = 0; i < arraysize(局_数量); i++)
        if(局_国家[i] == "國外")
            异常推播("出現異常國家「國外」")
            continue
        end
        if(arrayfindkey(Cw_国家网址, 局_国家[i]) > -1)
            局_讯息 = 局_讯息 & 局_国家[i] & ":" & 局_数量[i] & " "
            局_待发数量 = 局_待发数量 + cint(局_数量[i])
            var 局_等待时间 = 时间间隔("s", 时间转换(局_时间[i]), timenow())
            arraypush(C_待送国家, 局_等待时间, 局_国家[i])
        else
            wlog("Web_取待送國家", "取得異常國家名稱:" & 局_国家[i])
            sleep(10)
        end
        
    end
    traceprint(strformat("writeDeviceCount(%s,%s)", C_帐密[0], 局_待发数量))
    //    网页执行js("浏览器1",strformat("writeDeviceCount('%s','%s')",C_帐密[0],局_待发数量)) // 寫當前訂單的數量
    Firebase写订单数量(局_待发数量)
    wlog("Web_取待送國家", "國家列表為:" & 局_讯息 & "總共待發數量為" & 局_待发数量, false)
    if(局_待发数量 == 0)
        wlog("Web_取待送國家", "關閉Vpn", false)
        文件覆盖内容(C_个别资料夹 & "Action.txt", "CloseVpn", 2)
    end
    文件写配置("待發", C_帐密[0], 局_讯息, C_配置路径)
    Web_取超时国家()
    return 局_讯息
end

function Web_取超时国家(参_重新抓单 = false)
    var 局_Temp = array(), temp, 局_返回 = array(), 局_Key, 局_Value
    if(参_重新抓单)
        if(Web_取待送国家() == "")
            return ""
        end
    end
    var 局_时间 = 获取系统时间()
    for(var k = 0; k < arraysize(C_待送国家); k++)
        arraygetat(C_待送国家, k, 局_Value, 局_Key)
        数组增加元素(局_Temp, 局_Value, null, k)
    end
    for(var i = arraysize(局_Temp) - 1; i >= 1; i--)
        for(var j = 0; j <= i - 1; j++)
            if(局_Temp[j] < 局_Temp[j + 1])
                temp = 局_Temp[j]
                局_Temp[j] = 局_Temp[j + 1]
                局_Temp[j + 1] = temp
            end
        end
    end
    for(var i = 0; i < arraysize(局_Temp); i++)
        arraygetat(局_Temp, i, 局_Value, 局_Key)
        var 局_国家 = arrayfindvalue(C_待送国家, cint(局_Temp[i]))
        arraypush(局_返回, 局_Value, 局_国家)
    end
    C_待送国家 = 局_返回
    arraygetat(C_待送国家, 0, 局_Value, 局_Key)
    traceprint(获取系统时间() - 局_时间)
    traceprint(arraytostring(局_Temp))
    if(局_Value / 60 >= 5)
        wlog("Web_取超時國家", 局_Key & "超過五分鐘")
        return 局_Key
    end
    return ""
    
end

function Web_最久大於20秒(参_国家)
    // 目前等待最久的國家有沒有比傳進來的國家的等待時間超過60秒以上，沒有就返回當前國家讓他繼續發
    var 局_Value, 局_Key
    if(arrayfindkey(C_待送国家, 参_国家) == -1) //已經沒有當前國家了直接返回空
        return ""
    end
    var 局_正在发时间 = C_待送国家[参_国家] //当前正在发的国家的秒数
    for(var i = 0; i < arraysize(C_待送国家); i++)
        arraygetat(C_待送国家, i, 局_Value, 局_Key)
        if(C_待送国家[局_Key] - 20 > 局_正在发时间) //-60 还是超过目前发的只能返回现在发的给他，也就是说等待最久的国家已经超过正在发的国家60秒时会切换最久的国家回去
            wlog("Web_最久大於20秒", "切換到" & 局_Key)
            return 局_Key
        end
    end
    return 参_国家
end



function Web_取待送国家_是否发完(参_网页码)
    if(strfind(参_网页码, "發完") > -1)
        C_订单发送时间 = null
        arrayclear(C_待送国家)
        Web_取待送国家_其他待发(参_网页码)
        文件写配置("待發", C_帐密[0], "", C_配置路径)
        wlog("Web_取待送國家", "目前無訂單，抓取新訂單中")
        wlog("Web_取待送國家", "關閉Vpn", false)
        文件覆盖内容(C_个别资料夹 & "Action.txt", "CloseVpn", 2)
        editsettext("订单资料2", "")
        yes_订单数量检测()
        Sys_置讯息("目前無訂單，抓取新訂單中", true)
        Firebase_置发送状态()
        staticsettext("等待", "")
        Web_置VPN解锁()
    end
end

//判断是否其他手机有待发
function Web_取待送国家_其他待发(参_网页码)
    var 局_value, 局_key
    var 局_成果 = 正则子表达式匹配(参_网页码, "class=\"markText13 \">(\\w+)", true, true)  
    if(arraysize(局_成果) > 0)
        for(var i = 0; i < arraysize(局_成果); i++)
            arraygetat(局_成果, i, 局_value, 局_key)
            if(strfind(局_value, "march") > -1 || strfind(局_value, "yabe") > -1)
                窗口发送消息(窗口查找(局_value, "#32770"), 5000, 5000, 5000)
            end
            
        end
    end
    //正则子表达式匹配(局_Code,"<p id=\"para_2\" style=\"padding:5px 0px 0px 0px;\">([\\x{4e00}-\\x{9fa5}a-zA-Z0-9\\._-]+)",false,true,true)
end

function Web_取待送国家_整理国家(&参_国家)
    for(var i = 0; i < arraysize(参_国家); i++)
        参_国家[i] = 字符串截取(参_国家[i], 0, strfind(参_国家[i], "貼圖"))
    end
end



function Web_比对页面id和网址(参_ID, 参_网址)
    var web = "var a = $(\"[id=Name]\"); return a[1].value;"
    var id = "var a = document.getElementsByName(\"Line_ID\");return a[1].value;"
    wlog("Web_比對頁面id和網址", strformat("原本ID:%s 原本網址%s 網頁ID:%s 網頁網址:%s", 参_ID, 参_网址, 网页执行js("浏览器0", id), 网页执行js("浏览器0", web)), false)
    if(网页执行js("浏览器0", web) == 参_网址 && 网页执行js("浏览器0", id) == 参_ID)
        return true
    end
    return false
end

function Web_判断待加好友(参_原始码)
    if(arraysize(正则子表达式匹配(参_原始码, "待加好友- (\\d+)人\\d+圖", false, true)) >= 1)
        FireBase_置加好友状态()
    end
end

function FireBase_置加好友状态()
    if(!FireBase_取待加状态())
        webrunjs("浏览器1", "writeUserData('Y')")
    end
    
end

function FireBase_取待加状态()
    var 局_状态 = webrunjs("浏览器1", "return document.getElementById('friendstatus').innerText;")
    traceprint(局_状态)
    if(局_状态 == "N")
        return false
    end
    return true
end

function Firebase_置发送状态()
    //    if(时间间隔("s",timenow(),FireBase_时间)<7)
    //        wlog("Firebase_置发送状态","频繁调用FireBase 重开去")
    //        退出()
    //    end
    var obj = com("WinHttp.WinHttpRequest.5.1")
    obj.SetRequestHeader("Content-Type", "application/json")
    obj.Open("PATCH", "https://yabeline-ad17d.firebaseio.com/waitSend.json", false)
    var s = strformat("{\"%s\": \"%s\"}", C_帐密[0], "0")
    traceprint(s)
    traceprint(obj.Send(s))
    traceprint(obj.ResponseBody)
    traceprint(obj.ResponseText)
    obj = null   
    sleep(3000)
    FireBase_时间 = timenow()
    
end

function FireBase_取待发送状态()
    traceprint("document.getElementById('" & C_帐密[0] & "_count').innerText;")
    var 局_状态 = webrunjs("浏览器1", "return document.getElementById('" & C_帐密[0] & "_count').innerText;")
    traceprint(局_状态)
    if(局_状态 == "1")
        return true
    end
    return false
end

function Firebase_重置重启状态()
    var obj = com("WinHttp.WinHttpRequest.5.1")
    obj.SetRequestHeader("Content-Type", "application/json")
    obj.Open("PATCH", "https://yabeline-ad17d.firebaseio.com/restart.json", false)
    var s = strformat("{\"%s\": \"%s\"}", C_帐密[0], "")
    traceprint(s)
    traceprint(obj.Send(s))
    traceprint(obj.ResponseBody)
    traceprint(obj.ResponseText)
    obj = null   
    sleep(3000)
    FireBase_时间 = timenow()
end

function Firebase_取重启状态()
    var 局_状态 = webrunjs("浏览器1", "return document.getElementById('" & C_帐密[0] & "_restart').innerText;")
    traceprint(局_状态)
    if(局_状态 == "-100")
        return true
    end
    return false
end

function Firebase写订单数量(参_数量)
    return false
    var obj = com("WinHttp.WinHttpRequest.5.1")
    obj.SetRequestHeader("Content-Type", "application/json")
    obj.Open("PATCH", "https://yabeline-ad17d.firebaseio.com/waitStatus.json", false)
    var s = strformat("{\"%s\": \"%s\"}", C_帐密[0], 参_数量)
    traceprint(s)
    traceprint(obj.Send(s))
    traceprint(obj.ResponseBody)
    traceprint(obj.ResponseText)
    obj = null
end



function Sql_异常2增加(参_ID)
    var 局_数组 = array()
    var 局_成功 = sqlitesqlarray(C_DB_Error2_Path, strformat("insert into Error (Date_time,Custorm_ID) values (datetime('now','localtime'),'%s')", 参_ID), 局_数组)
    if(!局_成功)
        wlog("Sql給", "寫異常2失敗", false)
        //        wlog("Sql寫訂單","傳送資料給app失敗準備重開",true)
        //        sleep(5000)
        //        threadbegin("Yabe_Client_关闭","")
    end
end

function Sql_异常2次数(参_ID)
    var 局_数组 = array()
    sqlitesqlarray(C_DB_Error2_Path, strformat("SELECT * FROM Error WHERE Custorm_ID='%s' and Date_time between datetime(datetime('now', 'localtime'),'-60 minutes') and datetime('now', 'localtime')", 参_ID), 局_数组)
    if(!局_数组)
        wlog("Sql給", "查異常2失敗", false)
        return false
    end
    return arraysize(局_数组)
end

function Sql写订单(参_ID, 参_讯息)
    init_SqlPath()
    var 局_数组 = array()
    var 局_成功 = sqlitesqlarray(C_DB_Path, strformat("insert into log (id,訂單資料,接收時間) values ('%s','%s',datetime('now','localtime'))", 参_ID, 数组转资讯(参_讯息, "Status")), 局_数组)
    if(!局_成功)
        wlog("Sql給", "寫訂單給App失敗", false)
        wlog("Sql寫訂單", 数组转资讯(参_讯息, "Status"), false)
        //        wlog("Sql寫訂單","傳送資料給app失敗準備重開",true)
        //        sleep(5000)
        //        threadbegin("Yabe_Client_关闭","")
    end
end


function Sql写回报(参_ID, 参_讯息, 参_备注 = "")
    var 局_数组 = array()
    //设置剪切板(strformat("Update `log` set id='%s',處理結果='%s',處理時間=datetime('now','localtime'),備註='%s' where id='%s' and 處理結果 is null and 處理時間 is null",参_ID,参_讯息,参_备注,参_ID))
    var 局_结果 = sqlitesqlarray(C_DB_Path, strformat("Update `log` set id='%s',處理結果='%s',處理時間=datetime('now','localtime'),備註='%s' where id='%s' and 處理結果 is null and 處理時間 is null", 参_ID, 参_讯息, 参_备注, 参_ID), 局_数组)
    if(!局_结果)
        wlog("Sql寫回報", "資料寫入LogDB失敗")
    end
    
end

function flask_get_order_data()
    return http提交请求("get", "http://127.0.0.1:5000/order/get?device=" & C_帐密[0], "", "utf-8")
end

function Sqlite_读订单()
    var 局_数组 = array(), 局_资讯分割 = array()
    var result = flask_get_order_data()
    if(strfind(result, "已處理") > -1)
        strsplit(result, " | ", 局_资讯分割)
        return Sqlite_内部资讯分割(局_资讯分割)
    end
    
    if(!fileexist(C_个别资料夹 & "cread.txt"))
        traceprint("無權限讀取訂單" & timenow())
        
        return "無權限" //有單
    end
    return ""
    if(sqlitesqlarray(C_DB_OrderPath, "SELECT Data FROM `OrderData`", 局_数组))
        if(arraysize(局_数组) > 0 && 局_数组 != null)
            var 局_结果 = 局_数组[0]["Data"]
            if(局_数组[0]["Data"] == "")
                return ""
            end
            strsplit(局_数组[0]["Data"], " | ", 局_资讯分割)
            return Sqlite_内部资讯分割(局_资讯分割)
        end
    end
    return ""
end

function Sqlite_内部资讯分割(参_数组)
    var 局_暂存分割 = array(), 局_返回分割 = array()
    
    for(var i = 0; i < arraysize(参_数组); i++)
        if(参_数组[i] == "")
            break
        end
        if(strsplit(参_数组[i], "：", 局_暂存分割))
            arraypush(局_返回分割, 局_暂存分割[1], 局_暂存分割[0])
        end
    end
    return 局_返回分割
end



function Sqlite_写订单(参_Data)
    var 局_数组 = array(), 局_写入 = ""
    if(isarray(参_Data))
        局_写入 = 数组转资讯(参_Data)
    else
        局_写入 = 参_Data
    end
    traceprint("device=" & C_帐密[0] & "&order=" & 局_写入)
    var result = http提交请求("post", "http://127.0.0.1:5000/order/set", "device=" & C_帐密[0] & "&order=" & 局_写入)
    traceprint(http提交请求("get", "http://127.0.0.1:5000/", ""))
    
    if(局_写入 != "")
        if(sqlitesqlarray(C_DB_OrderPath, "SELECT COUNT() FROM [OrderData] LIMIT 500", 局_数组))
            return ""
            //            if(局_数组[0]["COUNT()"] == 0)
            //                sqlitesqlarray(C_DB_OrderPath, "Insert into `OrderData` (Data) values ('" & 局_写入 & "')", 局_数组)
            //                return ""
            //            end
        end
    end
    if(局_写入 != "")
        wlog("Sqlite_寫訂單", "準備開放權限給App", false)
        Sqlite_开放权限() //开放权限给 app读取
        wlog("Sqlite_寫訂單", "權限開放結果" & fileexist(C_个别资料夹 & "eread.txt"), false)
        return true
    end
    return ""
    
end

function Sqlite_开放权限()
    for(var i = 0; i < 10; i++)
        var 局_句柄 = 文件创建(C_个别资料夹 & "eread.txt", "CREATE_ALWAYS")
        sleep(200)
        if(fileexist(C_个别资料夹 & "eread.txt"))
            wlog("Sqlite_開放權限", "開放權限成功", false)
            文件关闭(局_句柄)
            return true
        end
        sleep(100)
    end
    if(!fileexist(C_个别资料夹 & "eread.txt"))
        wlog("Sqlite_開放權限", "開放權限失敗，等待程序自動排除", true)
        呼叫_Center_关闭()
    end
    
    return false
end

function Sqlite_24小时订单处理() //处理24小时以前订单发送记录
    var 局_路径 = C_个别资料夹 & C_帐密["0"] & ".db", 局_修改数量 = array()
    sqlitesqlarray(局_路径, "Delete from [log] where [處理時間] between datetime(datetime('now', 'localtime'),'-60 days') and datetime(datetime('now', 'localtime'),'-24 hour')", 局_修改数量)
    if(arraysize(局_修改数量) > 0)
        wlog("Sqlite_24小时订单处理", "刪除過去24小時前訂單:" & cstring(arraysize(局_修改数量)))
    end
end

function 数组转资讯(参_数组, 参_过滤 = "", 参_过滤空值 = false)
    var 局_讯息 = "", 局_Value, 局_Key
    for(var i = 0; i < arraysize(参_数组); i++)
        arraygetat(参_数组, i, 局_Value, 局_Key)
        if(参_过滤空值 && (局_Value == "" || 局_Value == false)) //過濾空值
            continue
        end
        if(strfind(参_过滤, 局_Key) == -1)
            局_讯息 = 局_讯息 & 局_Key & "：" & 局_Value & " | "
        end
    end
    return 局_讯息
end

function 数组转资讯推播整理(参_数组, 参_过滤 = "", 参_过滤空值 = false)
    var 局_ID = 参_数组["ID"]
    var 局_Message = 参_数组["Message"]
    var 局_备注
    var 局_贴图名称 = strreplace(参_数组["StkName"], "#", "")
    var 局_贴图网址 = 参_数组["LineWeb"]
    var 局_No = 参_数组["No"]
    var 局_网站编号 = strsub(参_数组["StkName"], 0, strfind(参_数组["StkName"], "-"))
    var 局_国家 = 参_数组["Country"]
    var 局_价钱 = 参_数组["Price"]
    var 局_收图者网址 = 缩网址("http://yabeline.tw/Admin_User.php?Line_ID=" & 局_ID)
    var 局_网站贴图网址 = 缩网址("http://yabeline.tw/Stickers_Search.php?Search=" & 局_网站编号)
    var 局_编辑, 局_lineStore = ""
    //var t = strformat("http://iyabetech.com/Yabe/sendrecord.php?No=%s",局_No) & "%26DeviceID="& C_帐密[0]
    var t = strformat("http://iyabetech.com/Yabe/sendrecord.php?DeviceID=%s", C_帐密[0]) 
    var 局_查询截图网址 = 缩网址(t)
    var 局_订单截图网址 = 缩网址("http://iyabetech.com/Yabe/sendrecord.php?No=" & 参_数组["No"])
    var 局_价格重跑 = ""
    if(参_数组["Remark"] || 参_数组["Remark"] != "")
        局_备注 = 参_数组["Remark"] & " | "
    end
    if(strfind(参_数组["Message"], "異常C") > -1)
        var 局_主题原始 = ""
        if(局_国家 == "日本")
            // https://yabeline.tw/showcaseData2017.php?hashcode=主題編號&proxy=tw
            局_主题原始 = "https://yabeline.tw/admin/product?q=" & 局_网站编号 & "&ptype=1"
            //局_价格重跑 = " | 【主題價格重跑】 | " &  缩网址("update/theme?q=" & strreplace(局_贴图网址,"line://shop/theme/detail?id=","")  & " | "
            //threadbegin("价格重跑","http://iyabe.tw/showcaseData2017.php?hashcode=" & strreplace(局_贴图网址,"line://shop/theme/detail?id=","")& "&proxy=ja")
        else
            局_主题原始 = "https://yabeline.tw/update/theme?q=" & strreplace(局_贴图网址, "line://shop/theme/detail?id=", "")
            
            //局_价格重跑 = " | 【主題價格重跑】 | " & 缩网址(局_主题原始) & " | "
            //threadbegin("价格重跑","http://iyabe.tw/showcaseData2017.php?hashcode=" & strreplace(局_贴图网址,"line://shop/theme/detail?id=","") & "&proxy=tw")
        end
        wlog("資訊推播整理", "主題重跑:\r\n" & 局_主题原始, false)
        
    end
    
    if(strfind(参_数组["LineWeb"], "shop/detai") > -1) // 如果是貼圖就是type1
        局_编辑 = "【編輯】" & " | " & 缩网址("https://yabeline.tw/admin/product?q=" & 局_网站编号 & "&ptype=1") 
        var 局_贴图编号 = 正则表达式匹配(局_贴图网址, "(\\d+)") 
        局_编辑 = 局_编辑 & " | " & 缩网址("https://yabeline.tw/update/sticker?q=" & 转字符型(局_贴图编号[0]))
    elseif(strfind(参_数组["LineWeb"], "emoji") > -1)
        var 局_贴图编号 = strreplace(局_贴图网址, "line://shop/emoji/detail?id=", "") 
        局_编辑 = "【編輯】 | " & 缩网址("https://yabeline.tw/update/emoji?q=" & 局_贴图编号)
    else
        局_编辑 = "【編輯】" & " | " & 缩网址("https://yabeline.tw/update/theme?q=" & strreplace(局_贴图网址, "line://shop/theme/detail?id=", ""))  // %26
    end
    var 局_讯息 = ""
    局_讯息 = strformat("%s | %sNo:%s |  | 【收圖者】 | %s | %s |  | 【貼圖】 | %s | ", 局_Message, 局_备注, 局_No, 局_ID, 局_收图者网址, 局_贴图名称)
    //if(strfind(局_贴图网址,"theme") == -1)  //2018.2.8 開會移除
    局_讯息 = 局_讯息 & strformat("%s | %s |  | %s |  | 【查詢截圖】 | %s | %s | Country:%s | Price:%s | ", 局_贴图网址, 局_网站贴图网址, 局_编辑, 局_订单截图网址, 局_查询截图网址, 局_国家, 局_价钱)
    //else
    //局_lineStore = strformat("https://store.line.me/themeshop/product/%s/zh-Hant",strreplace(局_贴图网址,"line://shop/theme/detail?id=",""))
    //     局_讯息 = 局_讯息 & strformat("%s | %s | %s |  | %s |  | 【查詢截圖】 | %s | %s | Country:%s | Price:%s | %s",局_lineStore,局_贴图网址,局_网站贴图网址,局_编辑,局_订单截图网址,局_查询截图网址,局_国家,局_价钱,局_价格重跑)
    //  end
    return 局_讯息
end

function 缩网址(参_网址)
    
    
    var 局_result = http提交请求("GET", "http://tinyurl.com/api-create.php?url=" & url编码(参_网址), "", "utf-8")
    return 局_result
end

function 价格重跑(参_网址)
    var 局_結果 = http提交请求("get", 参_网址, "", "utf-8", null, "", true, 10000)
    wlog("價格重跑", 局_結果)
end


function 资讯断行(参_字串, 参_url编码 = false)
    var 局_数组 = array(), 局_讯息 = ""
    参_字串 = 参_字串 & " " & 参_字串
    for(var i = 0; i < strsplit(参_字串, "|", 局_数组); i++)
        局_讯息 = 局_讯息 & 局_数组[i] & "\r\n"
    end
    if(参_url编码)
        return url编码(局_讯息)
    else
        return 局_讯息
    end
    
end

function 卡死重开检测()
    var 局_sql_path = init_卡死重开sql()
    var 局_结果 = array()
    sqlitesqlarray(局_sql_path, "select count(*) as 次數 from freeze where create_time > datetime(datetime('now', 'localtime'),'-5 minute')", 局_结果)
    if(局_结果)
        if(局_结果["0"]["次數"] >= 3)
            var order_id = 网页元素获取("浏览器0", "value", "id:Order_No", "Yabe_Client")
            if(order_id != "")
                var lineid = 网页元素获取("浏览器0", "value", "tag:INPUT&id:Line_ID&name:Line_ID&index:2", "Yabe_Client")
                
                var 局_Data = array()
                局_Data["No"] = order_id
                局_Data["Message"] = "異常Z-其他錯誤 - Manual_Handling26"
                局_Data["LineWeb"] = 网页元素获取("浏览器0", "value", "id:Name", "Yabe_Client")
                Web_API回报(局_Data)
                var 异常文字 = 局_Data["Message"] & " | 【修改訂單】 | " & 缩网址("https://yabeline.tw/Admin_User.php?Line_ID=" & lineid) & " | 備註: | ID含有異常符號例如空格"
                异常推播(异常文字)
            end
            wlog("卡死重開檢測", "連續卡死三次,檢查客人ID")
            异常推播("連續卡死三次,檢查客人ID", true)
            
            sleep(10 * 1000)
            呼叫_Center_关闭()
        else
            sqlitesqlarray(局_sql_path, "insert into freeze(create_time) values(datetime('now','localtime'))", 局_结果)
            
        end
    end
    
    
end

