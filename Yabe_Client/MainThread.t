function 主线程()
    // todo
    C_订单发送时间 = null
    var 局_是否有国家=""
    filewriteini("Action",C_帐密[0],"運行",C_配置路径)
    Sqlite_写订单("")
    while(true)
        //偵測是否已處理，日則選擇並回報，如果档案已处理或者空且待送国家>0就取订单
        
        if(arraysize(C_待送国家) > 0 && 读文档() == "" )  //读文档() == ""代表沒訂單
            var 局_Key
            arraygetat(C_待送国家,0,null,局_Key)
            if(局_Key == "國外")
                if(arraysize(C_待送国家)>1)
                    arraygetat(C_待送国家,1,null,局_Key)
                end
            end
            Web_取订单资料(局_Key)
        end
        检测订单超时()
        if(staticgettext("状态") != "已發送資料給APP端發圖")
            局_是否有国家 = Web_取待送国家()
        end
        
        var 局_处理订单 = yes_is已处理() //如果已经是回报订单 会返回真
        if(重开时间() && 读文档() == "" )//重开时间到了
            关闭模拟器() // 这里会关闭模拟器，并关闭自身
        end
        if(局_是否有国家 == "" || staticgettext("状态") == "已發送資料給APP端發圖")
            等待时间(间隔时间(局_处理订单),"等待")
        end
        
        逍遥_更新Apk()
    end
end

function AppCarshCheckThread()
    while(true)
        sleep(2000)
        AppCarshCheck()
    end
end

function AppCarshCheck()
    if(checkgetstate("不检测App崩溃"))
        return false
    end
    var 局_Path = C_个别资料夹 & "Running.txt"
    var 局_上次运行时间 = filereadex(局_Path)
    if(时间间隔("s",局_上次运行时间,当前时间())>120)
        异常推播("其他-APP疑似崩潰，正在等待恢復")
        staticsettext("状态","其他-APP疑似崩潰，正在等待恢復")
        threadsuspend(主线程)
        
        文件覆盖内容(局_Path,"") //清空避免下次再次讀到
        
        逍遥_关闭模拟器(false)
        sleep(10*1000)
        threadresume(主线程)
        //启动停止_点击()
    end
    
end
//剛回報完1秒
//還有未完成訂單2秒
//沒有未完成訂單 5000或者讀資訊
function 间隔时间(参_处理完订单)
    if(参_处理完订单)
        return 1000 //如果是刚处理完订单 ， 等一秒马上在循环
    end
    if(读文档() != "" && !参_处理完订单) //当前有订单
        return 2000
    end
    //刚处理完
    var 局_CD = filereadini("Refresh","RefreshTime",C_配置路径)
    if(局_CD == "" || 局_CD == null)
        return 5000 //如果是当前没订单预设等待5秒
    end
    staticsettext("状态","目前無訂單，抓取新訂單中")
    return cint(局_CD*1000)
end

function 等待时间(参_时间,参_讯息)
    if(参_时间 == 2000)
        staticsettext("状态","已發送資料給APP端發圖")
    end
    for(var i = 0; i < 参_时间/1000 ; i++)
        staticsettext("等待",参_讯息 & cstring((参_时间/1000)-i))
        sleep(1000)
    end
end

function 重开时间()
    var 局_重开路径 = C_Noxshare & "Config\\Restart.txt"
    var 局_小时 = filereadex(局_重开路径)
    if(局_小时 == "" || 局_小时 == null)
        return false
    end
    
    var now = 当前时间() 
    var 局_重开时间差 = 时间间隔("s",now,filereadini("CenterConfig","LastReStartTime",C_配置路径))
    if(局_重开时间差>-300 && 局_重开时间差<0) //计算五分钟内是否重开过
        return false
    end
    var 局_关闭时间 = strformat("%s/%s/%s %s:00",时间年(now),时间月(now),时间日(now),局_小时)
    var 局_关闭前5分 = 指定时间("n",-5,局_关闭时间)
    // traceprint(局_关闭时间)
    // traceprint(局_关闭前5分)
    // traceprint(时间间隔("n",局_关闭时间,now))
    //  traceprint(时间间隔("n",局_关闭前5分,now)) 
    if(时间间隔("n",局_关闭时间,now) < 0 && 时间间隔("n",局_关闭前5分,now)> 0)
        traceprint("关闭的时间")  // 如果在關閉時間而且讀取出來又是Restart的話關閉模擬器並自我退出
        return true
    end
end

function 检测订单超时()
    if(!C_订单发送时间)
        return null
    end
    var 局_超时 = 时间间隔("s",C_订单发送时间,当前时间())
    if(局_超时 > 40)
        wlog("檢測訂單超時","目前訂單已經發送" & 时间间隔("s",C_订单发送时间,当前时间()) & "秒")
    end
    
    if(局_超时>300)
        wlog("檢測訂單超時","訂單發送後超過5分鐘沒發圖，請察看機器是否異常")
        异常推播("訂單發送後超過5分鐘沒發圖，請察看機器是否異常")
        启动停止_点击()
    end
end

function 关闭模拟器()
    var 局_讯号 = filereadex(C_个别资料夹 & "isRestart.txt")
    traceprint(局_讯号)
    if(局_讯号 == "ReStart")
        逍遥_关闭模拟器(true)
    end
end