
function yes_is已处理() //局_疑似发送资料
    var 局_跳转失败 = true, 局_内容  = "",局_Data
    局_内容 = Sqlite_读订单()
    局_Data = stringtoarray(局_内容)
    if(strfind(局_内容,"已處理") == -1)
        return false
    end
    Sqlite_24小时订单处理() 
    C_订单发送时间 = null
    wlog("yes_is已處理","收到訂單已處理，準備回報網站")
    while(true)
        
        yes_is已处理_首次检测页面资料(局_Data) //检测当前页面资料，不符合则跳转等待2000秒
        局_跳转失败 = yes_is已处理_等待页面跳转(局_Data)
        if(局_跳转失败)//todo 設定回報
            wlog("yes_is已處理","跳到回報頁面失敗  要回報的資料:" & 数组转资讯(局_Data))
            异常推播("Client已停止請人工處理 原因：需回報訂單，與頁面資料不相符 " & 数组转资讯推播整理(局_Data,"",true))
            启动停止_点击()
            continue
        end
        bmpToGif()
        if(!Web_资料符合(Cw_国家网址[局_Data["Country"]])) //檢測頁面上的資料，是否一致
            return false
        end
        //以下為回報
        var 局_回报结果 = Web_点选Boss(局_Data["Message"],局_Data) //写回报后会把Order.txt净空
        if(!局_回报结果 && C_回报失败次数 < 3)
            C_回报失败次数++
            wlog("yes_is已處理","回報失敗,次數: " & cstring(C_回报失败次数+1) & " 次,等待10秒")
            sleep(10*1000)
            continue
        elseif(!局_回报结果 && C_回报失败次数 >= 3)
            wlog("yes_is已處理","回報失敗次數到達 " & cstring(C_回报失败次数+1) & " 次")
            异常推播(C_帐密[0] & "回報失敗次數到達 " & cstring(C_回报失败次数+1) & " 次")
            Sys_错误停止("回報失敗次數到達 " & cstring(C_回报失败次数+1) & " 次")
            启动停止_点击()
        elseif(局_回报结果)
            C_订单数量 = C_订单数量 +1
            init_删除文件锁()
            editsettext("订单资料2","")
            C_回报失败次数 = 0
            Web_取待送国家("yes_已處理")
            if(combogettext("优先国家") != "") //取手動優先國
                if(!Web_取订单资料(combogettext("优先国家"))) //沒有優先國的訂單
                    wlog("yes_is已處理","沒有優先國家的訂單了")
                    combosetcursel("优先国家",-1)
                else
                    if(Web_取订单资料(局_Data["Country"]))//再次取同一個國家看看
                        wlog("yes_is已處理","有相同國家訂單")
                    else
                        wlog("yes_is已處理","無相同國家訂單")
                    end  
                end
                
            end
            return true
        end
    end
end





function yes_is已处理_检测已有此图(参_数组资料) //检测App是否已經發過此圖，可能是上一个回报失败
    var 局_返回 = array()
    
    var 局_cmd2 = "select * from log where (APP處理結果 = '已送出 - Success' or APP處理結果 = '補送成功 - Try_again_Ok') and 訂單資料 like '%" & 参_数组资料["LineWeb"] &"%' and id = '" & 参_数组资料["ID"] & "' order by 處理時間"
    wlog("yes_is已處理檢測已有此圖",局_cmd2,false)
    var 局_时间 = 获取系统时间()
    sqlitesqlarray(C_个别资料夹 & C_帐密[0] & ".db",局_cmd2,局_返回)
    if(!fileexist(C_个别资料夹 & C_帐密[0] & ".db"))
        wlog("yes_is已處理檢測已有此圖","App發送記錄資料庫不存在")
    end
    wlog("yes_is已處理檢測已有此圖","已送出或補送成功筆數" & cstring(arraysize(局_返回)))
    if(arraysize(局_返回) > 0)
        wlog("yes_is已處理檢測已有此圖","疑似有回報失敗已發送的貼圖",true)
        
        if(!C_调试)
            参_数组资料["Message"] = "異常Z-其他錯誤 - Manual_Handling26"
            参_数组资料["Remark"] = "疑似有回報失敗已發送的貼圖"
            wlog("yes_is已处理_檢測已有此圖","疑似有回報失敗已發送的貼圖，被回報為已有此圖資料為:" & 数组转资讯(参_数组资料,"",true))
            Sys_置讯息("疑似有回報失敗已發送的貼圖")
            wlog("yes_is已处理_檢測已有此圖","實際回報狀態為" & http获取页面源码(C_网域 & "LastStatus.php?Device=" & C_帐密[0] & "&No=" & 参_数组资料["No"],"utf-8"),false)
            //异常推播("疑似有回報失敗已發送的貼圖，被回報為已有此圖資料為:" & 数组转资讯推播整理(参_数组资料,"",true))
            webgo("浏览器0",Cw_国家网址[参_数组资料["Country"]])
            sleep(5000)
            Web_点选Boss("異常Z-其他錯誤 - Manual_Handling26",参_数组资料)
            return false
            //启动停止_点击()
        end
        
        
    end
    return true
end

function yes_is已处理_首次检测页面资料(参_数组资料)
    if(!Web_比对页面id和网址(参_数组资料["ID"],参_数组资料["LineWeb"]))
        webgo("浏览器0",Cw_国家网址[参_数组资料["Country"]])
        sleep(2000)
    end
end

function yes_is已处理_等待页面跳转(参_数组资料)
    var 局_跳转失败 = true
    for(var i = 0; i < 30; i++)
        Sys_置讯息("發圖結果回報網站",true)
        var 局_结果 = Web_比对页面id和网址(参_数组资料["ID"],参_数组资料["LineWeb"])
        if(局_结果)
            局_跳转失败 = false // 跳转成功
            break
        end
        if(i%5 == 0)
            webgo("浏览器0",Cw_国家网址[参_数组资料["Country"]])
            wlog("yes_is已處理_等待頁面跳轉","等待頁面跳轉失敗，第" & cstring(i/5) & "次")
        end
        sleep(500)
    end
    return 局_跳转失败
end

function yes_订单数量检测()
    var 局_限制 = 50
    filewriteini("訂單數",C_帐密[0],cstring(C_订单数量),C_配置路径)
    
    if(C_订单数量>=局_限制)
        filewriteini("訂單數",C_帐密[0],局_限制,C_配置路径)
        Sys_置讯息("處理已達30次，重開模擬器釋放記憶體",true)
        wlog("yes_訂單數量檢測","處理已達30次，重開模擬器釋放記憶體")
        逍遥_关闭模拟器(false)
        filewriteini("訂單數",C_帐密[0],"0",C_配置路径)
        var 局_重开等待 = filereadini("CenterConfig","StartAppDelay","C:\\Status.ini")
        wlog("yes_訂單數量檢測","重開等待"& 局_重开等待 &"秒")
        等待时间(局_重开等待*1000,"")
        C_订单数量 = 0
    end
end

function yes_写订单(参_资料)
    Sqlite_写订单(参_资料)
end

function 逍遥_关闭模拟器(参_是否退出 = true)
    xy_关闭模拟器("MEmu_" & cstring(C_帐密["id"]))
    if(参_是否退出)
        退出()
    end
end