
function yes_is已处理()
    var 局_跳转失败 = true
    var 局_内容 = Sqlite_读订单()
    if(strfind(局_内容,"已處理")>-1)
        C_订单发送时间 = null
        wlog("yes_is已處理","收到訂單已處理，準備回報網站")
        while(true)
            var 局_Data = stringtoarray(局_内容)
            if(!Web_比对页面id和网址(局_Data["ID"],局_Data["LineWeb"]))
                webgo("浏览器0",Cw_国家网址[局_Data["Country"]])
                sleep(2000)
            end
            for(var i = 0; i < 15; i++)
                staticsettext("状态","發圖結果回報網站")
                Sys_置讯息("發圖結果回報網站")
                var 局_结果 = Web_比对页面id和网址(局_Data["ID"],局_Data["LineWeb"])
                if(局_结果)
                    局_跳转失败 = false
                    break
                end
                traceprint("局_结果" & 局_结果)
                sleep(1000)
            end
            if(局_跳转失败)//todo 設定回報
                wlog("yes_is已處理","跳到回報頁面失敗  要回報的資料:" & 数组转资讯(局_Data))
                continue
            end
            if(!Web_资料符合(Cw_国家网址[局_Data["Country"]]))
                return false
            end
            //staticsettext("订单资料","")
            
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
                editsettext("订单资料2","")
                C_回报失败次数 = 0
                yes_订单数量检测()
                if(Web_取订单资料(局_Data["Country"]))//再次取同一個國家看看
                    wlog("yes_is已處理","有相同國家訂單")
                end
                Web_取待送国家()
                return true
            end
        end
        
    end
    return false
end

function yes_订单数量检测()
    var 局_限制 = 30
    C_订单数量 = C_订单数量 +1
    filewriteini("訂單數",C_帐密[0],cstring(C_订单数量),C_配置路径)
    if(C_订单数量>=局_限制)
        filewriteini("訂單數",C_帐密[0],局_限制,C_配置路径)
        Sys_置讯息("處理已達30次，重開模擬器釋放記憶體")
        wlog("yes_訂單數量檢測","處理已達30次，重開模擬器釋放記憶體")
        staticsettext("状态","處理已達30次，重開模擬器釋放顯卡記憶體")
        sleep(2000)
        filewriteini("訂單數",C_帐密[0],"0",C_配置路径)
        逍遥_关闭模拟器(false) // todo 写重开记录
        sleep(15*1000)
        C_订单数量 = 0
    end
end

function yes_写订单(参_资料)
    Sqlite_写订单(参_资料)
    //文件写配置("Order",C_帐密[0] & "_ID",参_资料,Cy_OrderPath)
end

function 逍遥_关闭模拟器(参_是否退出 = true)
    xy_关闭模拟器("MEmu_" & cstring(C_帐密["id"]))
    if(参_是否退出)
        退出()
    end
end