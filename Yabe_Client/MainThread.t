function 主线程()
    // todo
    filewriteini("Action",C_帐密[0],"運行",C_配置路径)
    文件覆盖内容(Cy_OrderPath,"",2)
    while(true)
        //偵測是否已處理，日則選擇並回報，如果档案已处理或者空且待送国家>0就取订单
        //traceprint("待送数量:" & arraysize(C_待送国家))
        if(arraysize(C_待送国家) > 0 && 读文档() == "" )  //读文档() == ""代表沒訂單
            var 局_Key
            arraygetat(C_待送国家,0,null,局_Key)
            Web_取订单资料(局_Key)
        end
        Web_取待送国家()
        var 局_处理订单 = yes_is已处理() //如果已经是回报订单 会返回真
        if(重开时间() && 读文档() == "" )//重开时间到了
            关闭模拟器() // 这里会关闭模拟器，并关闭自身
        end
        sleep(间隔时间(局_处理订单))
    end
end

function 间隔时间(参_处理完订单)
    if(参_处理完订单)
        return 1000 //如果是刚处理完订单 ， 等一秒马上在循环
    end
    var 局_CD = filereadini("Refresh","RefreshTime",C_配置路径)
    if(局_CD == "" || 局_CD == null)
        return 5000 //如果是当前没订单预设等待5秒
    end
    return cint(局_CD*1000)
end

function 重开时间()
    var 局_重开路径 = C_Noxshare & "Config\\Restart.txt"
    var 局_小时 = filereadex(局_重开路径)
    if(局_小时 == "" || 局_小时 == null)
        return false
    end
    var now = 当前时间() 
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

function 关闭模拟器()
    var 局_讯号 = filereadex(C_个别资料夹 & "isRestart.txt")
    traceprint(局_讯号)
    if(局_讯号 == "ReStart")
        yes_关闭模拟器()
    end
end