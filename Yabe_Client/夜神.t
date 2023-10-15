var bmpToGifThread = ""
function yes_is已处理() //局_疑似发送资料
    var 局_跳转失败 = true, 局_内容 = "", 局_Data, 局_资料是否为空 = false
    局_内容 = Sqlite_读订单()
    局_Data = stringtoarray(局_内容)
    if(strfind(局_内容, "已處理") == -1)
        return false
    end
    //Sqlite_24小时订单处理() 
    C_订单发送时间 = null
    wlog("yes_is已處理", "收到訂單已處理，準備回報網站")
    wlog("yes_is已處理", 局_内容)
    var times2 = 0
    while(true)
        wlog("yes_is已處理","循環中" & 转字符型(times2))
        times2 = times2 + 1
        //以下為回報
        
        var 局_回报结果 = Web_回报订单(局_Data["Message"], 局_Data) //写回报后会把Order.txt净空
        if(!局_回报结果)
            wlog("局_回报结果", "局_回報結果失敗")
        end
        if(!局_回报结果 && C_回报失败次数 < 3)
            C_回报失败次数++
            wlog("yes_is已處理", "回報失敗,次數: " & cstring(C_回报失败次数 + 1) & " 次,等待10秒")
            sleep(10 * 1000)
            continue
        elseif(!局_回报结果 && C_回报失败次数 >= 3)
            wlog("yes_is已處理", "回報失敗次數到達 " & cstring(C_回报失败次数 + 1) & " 次")
            异常推播(C_帐密[0] & "回報失敗次數到達 " & cstring(C_回报失败次数 + 1) & " 次")
            //Sys_错误停止("回報失敗次數到達 " & cstring(C_回报失败次数 + 1) & " 次")
            呼叫_Center_关闭()
        elseif(局_回报结果)
            filewriteex(C_个别资料夹 & "Running.txt",当前时间())
            C_订单数量 = filereadini("訂單數", C_帐密[0], C_配置路径) + 1
            filewriteini("訂單數", C_帐密[0], C_订单数量, C_配置路径)
            wlog("yes_is已處理", "已處理訂單數量" & cstring(C_订单数量))
            editsettext("订单资料2", "")
            init_删除文件锁()
            C_回报失败次数 = 0
            bmpToGifThread = threadbegin("八秒执行转档", "")
            // Web_取待送国家()
            if(yes_手动优先国家处理(局_Data["Country"]))
                return true
            end
            var 局_超时国家 = Web_取超时国家(true) // 这里会判断是否超时5分钟以上的订单，有的话会直接返回超过5分钟的国家
            if(局_超时国家 != "") //代表已经有5分钟的国家
                局_超时国家 = Web_最久大於20秒(局_Data["Country"]) // 判断当前国家，如果是空就代表當前國家早就發完了，如果
                if(Web_取订单资料(局_超时国家))
                    return true
                end
            end
            
            if(Web_取订单资料_单纯取资料(局_Data["Country"]))
                wlog("yes_is已處理", "繼續發" & 局_Data["Country"])
                return 
            else
                wlog("yes_is已處理", "目前無相同國家")
            end
            return true
        end
    end
end



function yes_手动优先国家处理(参_当前国)
    if(combogettext("优先国家") != "") // 目前有优先国家待发
        // 局_待送国家 = Web_取待送国家()
        var 局_优先国家有订单 = Web_取订单资料(combogettext("优先国家"))
        if(!局_优先国家有订单) //沒有優先國的訂單   strfind(局_待送国家,combogettext("优先国家")) == -1
            wlog("yes_is已處理", "沒有優先國家的訂單了")
            combosetcursel("优先国家", -1)
        else //优先国家有订单
            if(局_优先国家有订单)
                sleep(1000)
                return true
            end
            if(Web_取订单资料(参_当前国))//再次取同一個國家看看  strfind(局_待送国家,局_Data["Country"]) > -1 
                //Web_取订单资料(局_Data["Country"])
                wlog("yes_is已處理", "有相同國家訂單")
            else
                wlog("yes_is已處理", "無相同國家訂單")
            end  
        end
    end
end

function yes_is已处理_检测已有此图(参_数组资料) //检测App是否已經發過此圖，可能是上一个回报失败
    return false
    var 局_返回 = array()
    var 局_cmd2 = "select * from log where (APP處理結果 = '已送出 - Success' or APP處理結果 = '補送成功 - Try_again_Ok') and 訂單資料 like '%" & 参_数组资料["LineWeb"] & "%' and id = '" & 参_数组资料["ID"] & "' order by 處理時間"
    wlog("yes_is已處理檢測已有此圖", 局_cmd2, false)
    var 局_时间 = 获取系统时间()
    sqlitesqlarray(C_个别资料夹 & C_帐密[0] & ".db", 局_cmd2, 局_返回)
    if(!fileexist(C_个别资料夹 & C_帐密[0] & ".db"))
        wlog("yes_is已處理檢測已有此圖", "App發送記錄資料庫不存在")
    end
    wlog("yes_is已處理檢測已有此圖", "已送出或補送成功筆數" & cstring(arraysize(局_返回)))
    if(arraysize(局_返回) > 0)
        if(!C_调试)
            参_数组资料["Message"] = "異常Z-其他錯誤 - Manual_Handling26"
            参_数组资料["Remark"] = "疑似有回報失敗已發送的貼圖"
            wlog("yes_is已处理_檢測已有此圖", "疑似有回報失敗已發送的貼圖，被回報為已有此圖資料為:" & 数组转资讯(参_数组资料, "", true))
            wlog("yes_is已处理_檢測已有此圖", arraytostring(局_返回), false)
            Sys_置讯息("疑似有回報失敗已發送的貼圖")
            wlog("yes_is已处理_檢測已有此圖", "實際回報狀態為" & http获取页面源码(C_网域 & "LastStatus.php?Device=" & C_帐密[0] & "&No=" & 参_数组资料["No"], "utf-8"), false)
            webgo("浏览器0", Cw_国家网址[参_数组资料["Country"]])
            sleep(5000)
            
            //if(Web_比对页面id和网址(参_数组资料["ID"],参_数组资料["LineWeb"]))
            wlog("yes_is已处理_檢測已有此圖", "當前頁面資料符合回報異常Z")
            Web_回报订单(参_数组资料["Message"], 参_数组资料)
            // else
            wlog("yes_is已处理_檢測已有此圖", "網頁資料比對異常")
            // end
            var text = webrunjs("浏览器0", "return document.getElementsByTagName('body')[0].innerText")
            wlog("", text)
            Web_判断待加好友(text)
            
            //启动停止_点击()
        end
        return true
    end
    return false
end

function yes_is已处理_首次检测页面资料(参_数组资料)
    if(!Web_比对页面id和网址(参_数组资料["ID"], 参_数组资料["LineWeb"]))
        webgo("浏览器0", Cw_国家网址[参_数组资料["Country"]])
        sleep(2000)
    end
end

function yes_is已处理_等待页面跳转(参_数组资料)
    var 局_跳转失败 = true
    for(var i = 0; i < 30; i++)
        Sys_置讯息("發圖結果回報網站", true)
        var 局_结果 = Web_比对页面id和网址(参_数组资料["ID"], 参_数组资料["LineWeb"])
        if(局_结果)
            局_跳转失败 = false // 跳转成功
            break
        end
        if(i % 5 == 0)
            webgo("浏览器0", Cw_国家网址[参_数组资料["Country"]])
            wlog("yes_is已處理_等待頁面跳轉", "等待頁面跳轉失敗，第" & cstring(i / 5) & "次")
        end
        sleep(500)
    end
    return 局_跳转失败
end

function yes_订单数量检测()
    var 局_限制 = 25
    
    if(filereadini("Config", "重開數量", C_配置路径) != "")
        局_限制 = cint(filereadini("Config", "重開數量", C_配置路径))
    end
    wlog("yes_訂單數量檢測", "局_限制: " & cstring(局_限制), false)
    C_订单数量 = filereadini("訂單數", C_帐密[0], C_配置路径)
    filewriteini("訂單數", C_帐密[0], cstring(C_订单数量), C_配置路径)
    
    //wlog("yes_訂單數量檢測","FileExists" & dllcall("shlwapi.dll","int","PathFileExistsA","char *",C_个别资料夹 & "Action.txt"),false)
    // wlog("yes_訂單數量檢測",C_个别资料夹 & "Action.txt",false)
    
    if(C_订单数量 >= 局_限制 && !filereadex(C_个别资料夹 & "Action.txt")) //&& dllcall("shlwapi.dll","int","PathFileExistsA","char *",C_个别资料夹 & "Action.txt") != 1
        filewriteini("訂單數", C_帐密[0], 局_限制, C_配置路径)
        Sys_置讯息("處理已達" & cstring(局_限制) & "次，重開模擬器釋放記憶體", true)
        wlog("yes_訂單數量檢測", "處理已達" & 局_限制 & "次，重開模擬器釋放記憶體")
        逍遥_关闭模拟器(false)
        filewriteini("訂單數", C_帐密[0], "0", C_配置路径)
        var 局_重开等待 = filereadini("CenterConfig", "StartAppDelay", C_配置路径)
        wlog("yes_訂單數量檢測", "重開等待" & 局_重开等待 & "秒")
        等待时间(局_重开等待 * 1000, "")
        C_订单数量 = 0
    end
end

function yes_写订单(参_资料)
    Sqlite_写订单(参_资料)
end

function flask_取名称()
    var 局_模拟器名 = http提交请求("get", "http://127.0.0.1:5000/find_device?model=" & C_帐密["0"], "", "utf-8")
    if(strfind(局_模拟器名, "MEmu") > -1)
        return 局_模拟器名
    end
    return ""
end

function 逍遥_关闭模拟器(参_是否退出 = true)
    var 局_名称 = flask_取名称()
    //    if(局_名称)
    xy_关闭模拟器(cstring(C_帐密[0]))
    if(参_是否退出)
        wlog("逍遙_關閉模擬器", "準備關閉自身Client")
        呼叫_Center_关闭()
        
    end
    //    else
    //        wlog("逍遙_關閉模擬器","關閉模擬器時獲取名稱失敗")
    //    end
    
end