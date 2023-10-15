var G_上次取订单的时间 = null

function 取发图状态()
    if(!fileexist(C_个别资料夹 & "發圖中.txt"))
    end
end

function 是否已处理()
    return strfind(flask_get_order_data(), "已處理") > -1
end

function 是否发图中()
    var result = flask_get_order_data()
    return strfind(result, "已接收") > -1 || strfind(result, "未接收") > -1
end

function 主线程()
    C_订单发送时间 = null
    Global_源码开关 = false
    var 局_是否有国家 = ""// Mainthread循环一次小于5秒代表卡死 会等待5秒后重开
    filewriteini("Action", C_帐密[0], "運行", C_配置路径)
    Sqlite_写订单("")
    while(true)
        //偵測是否已處理，日則選擇並回報，如果档案已处理或者空且待送国家>0就取订单
        if(arraysize(C_待送国家) > 0)  
            if(!fileexist(C_个别资料夹 & "發圖中.txt") && !是否发图中()) //無權限代表不能讀爾以
                var 局_Key
                arraygetat(C_待送国家, 0, null, 局_Key)
                if(局_Key == "國外")
                    if(arraysize(C_待送国家) > 1)
                        arraygetat(C_待送国家, 1, null, 局_Key)
                    end
                end
                //if(!combogettext("优先国家"))
                //     yes_手动优先国家处理()
                // end
                Web_取订单资料(局_Key)
            end
            
            //Web_判断待加好友(局_Code)
        end
        
        if(staticgettext("状态") != "已發送資料給APP端發圖" && !fileexist(C_个别资料夹 & "發圖中.txt") && !是否发图中())
            局_是否有国家 = Web_取待送国家("MainThread")
        end
        var 局_处理订单 = yes_is已处理() //如果已经是回报订单 会返回真
        var 发图中 = 是否发图中()
        if(发图中)
            检测订单超时()
        end
        if(局_是否有国家 == "" || staticgettext("状态") == "已發送資料給APP端發圖" || fileexist(C_个别资料夹 & "發圖中.txt") || 发图中)
            等待时间(间隔时间(局_处理订单, 发图中), "等待")
            
        end
        
        //逍遥_更新Apk()
    end
end

function AppCarshCheckThread()
    
    while(true)
        sleep(2000)
        AppCarshCheck()
        for(var i = 0; i < 10 && Global_源码开关; i++)
            if(i == 9)
                wlog("AppCarshCheckThread", "獲取網頁資料超時，重新開始")
                threadclose(主线程)
                C_重开次数++
                if(C_重开次数 >= 2)
                    wlog("AppCarshCheckThread", "獲取網頁資料失敗次數過多，準備重開")
                    呼叫_Center_关闭()
                    break
                end
                sleep(2000)
                主线程 = threadbegin("主线程", "")
            end
            if(i > 5)
                wlog("AppCarshCheckThread", "獲取網頁資料超時" & i & "秒")
            end
            sleep(1000)
        end
    end
end

function bmpToGif(参_转档 = true)
    // var 局_迁移路径 = "C:\\Users\\Sticker_Sen\\AppData\\Roaming\\Microsoft\\Windows\\Network Shortcuts\\yabeOrder\\"
    
    var 局_迁移路径 = "Z:\\",局_限制 = 500
    wlog("bmpToGif", "bmpToGif開始", false)
    // var dll = com("bmpToGif.imageClass"),
    var 局_文件列表 = array()
    var cmdline = "move " & C_个别资料夹 & "訂單截圖\\* Z:\\"
    //filewriteex(C_个别资料夹 & "move.bat",cmdline)
    //cmd("C:\\move.bat",true)
    //   openprocess("C:\\move.bat")
    //    if(!cmd(cmdline,false))
    //         wlog("bmpToGif",cmdline)
    //    end
    checkUpload(局_限制)
    if(!fileexist(局_迁移路径))
        wlog("bmpToGif", "遷移路徑不存在")
        return
    end
    if(!参_转档)
        局_限制 = 100
    end
    文件遍历(C_个别资料夹 & "訂單截圖", 局_文件列表, null)
    for(var i = 0; i < arraysize(局_文件列表) && i <= 局_限制; i++)
        if(strfind(局_文件列表[i], ".bmp") > -1 && 参_转档)
            //  dll.bmpToGif(C_个别资料夹 & "訂單截圖\\" & 局_文件列表[i],"C:\\xampp\\htdocs\\" & strreplace(局_文件列表[i],".bmp",".gif"))
            // messagebox(系统获取进程路径() & "bmpToGifExe.exe " & C_个别资料夹 & "訂單截圖\\" & 局_文件列表[i] &" C:\\xampp\\htdocs\\" & strreplace(局_文件列表[i],".bmp",".gif"))
            sleep(500)
            cmd(系统获取进程路径() & "bmpToGifExe.exe " & C_个别资料夹 & "訂單截圖\\" & 局_文件列表[i] & " " & 局_迁移路径 & strreplace(局_文件列表[i],".bmp",".gif"),true)
        elseif(strfind(局_文件列表[i], ".png") > -1)
            if(取文件大小(C_个别资料夹 & "訂單截圖\\" & 局_文件列表[i],true) == "0 KB")
                filedelete(C_个别资料夹 & "訂單截圖\\" & 局_文件列表[i])
                continue
            end
            wlog("bmpToGif", "檔案準備移動", false)
            filemove(C_个别资料夹 & "訂單截圖\\" & 局_文件列表[i],局_迁移路径 & 局_文件列表[i])
            wlog("bmpToGif", "檔案移動完成", false)
        end
    end
    //dll = null
    wlog("bmpToGif", "bmpToGif結束", false)
    
end

function checkUpload(参_限制)
    var 局_文件列表 = array()
    var head = array()
    wlog("checkUpload", "確認checkUpload", false)
    var result = http提交请求("get", "http://www.yabebaby.synology.me/Yabe/upload.php?isLive=123", "", "utf-8", head, "", true, 1000)
    wlog("checkUpload", "確認checkUpload結果", false)
    if(result != "ok")
        return false
    end
    文件遍历(C_个别资料夹 & "訂單截圖", 局_文件列表, null)
    for(var i = 0; i < arraysize(局_文件列表) && i <= 参_限制; i++)
        
        var 局_大小 = 取文件大小(C_个别资料夹 & "訂單截圖\\" & 局_文件列表[i]) 
        wlog("checkUpload", 局_文件列表[i] & "," & 局_大小)
        if(局_大小 == "0 個位元組" || 局_大小 == "0 kb" || 局_大小 == "")
            wlog("checkUpload", "刪除截圖失敗檔案")
            filedelete(C_个别资料夹 & "訂單截圖\\" & 局_文件列表[i])
            continue
        end
        var header = 数组()
        header["Accept"] = "*/*"
        header["User-Agent"] = "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:17.0) Gecko/17.0 Firefox/17.0"
        header["Accept-Language"] = "zh-CN,en-US;q=0.5"
        header["Accept-Encoding"] = "deflate"
        header["Cache-Control"] = "no-cache"
        result = http上传("http://yabebaby.synology.me/Yabe/upload.php", "", "file@" & C_个别资料夹 & "訂單截圖\\" & 局_文件列表[i],"utf - 8",header)
        
        traceprint(result)
        filedelete(C_个别资料夹 & "訂單截圖\\" & 局_文件列表[i])
    end
end

function AppCarshCheck()
    if(checkgetstate("不检测App崩溃"))
        return false
    end
    var 局_Path = C_个别资料夹 & "Running.txt"
    var 局_上次运行时间 = filereadex(局_Path)
    C_App运行时间 = 时间间隔("s", 局_上次运行时间, 当前时间())
    if(!C_App运行时间 || C_App运行时间 == "")
        if(!C_超时时间)
            C_超时时间 = 当前时间()
        end
        // wlog("超","為空時間" & 时间间隔("s",当前时间(),C_超时时间))
        if(时间间隔("s", 当前时间(), C_App运行时间) < -150)
            wlog("AppCarshCheck", "二次重開" & 转字符型(时间间隔("s", 当前时间(), C_App运行时间)), true)
            //            xy_关闭模拟器(C_帐密[0])
            C_超时时间 = null
        end
        
    else
        C_超时时间 = null
    end
    if(C_App运行时间 > 100 || C_App运行时间 < -150)
        if(!C_调试)
            局_上次运行时间 = 当前时间()
        end
        文件覆盖内容(局_Path, "") //清空避免下次再次讀到
        //filewriteex(C_个别资料夹 & "\\apkver.txt", 1)
        
        逍遥_关闭模拟器(false)
        sleep(30 * 1000)
        staticsettext("状态", "其他-APP疑似崩潰，正在等待恢復")
        wlog("AppCarshCheck", "其他-APP疑似崩潰，正在等待恢復給予30秒緩衝啟動" & 局_Path)
        threadsuspend(主线程)
        sleep(10 * 1000)
        
        threadresume(主线程)
        
    end
    if(C_App运行时间 > 50 )
        var vms = xy_listvms()
        
        if(arrayfindkey(vms, C_帐密[0]) == -1)
            return 
        end
        var index = vms[C_帐密[0]]["index"]
        xy_memuc_adb(index,"shell am start -n auto.yabeline.myapplication2/auto.yabeline.myapplication2.MainActivity")
        sleep(10*1000)
    end
    
    
end

//剛回報完1秒
//還有未完成訂單2秒
//沒有未完成訂單 5000或者讀資訊

function 间隔时间(参_处理完订单,发图中)
    if(参_处理完订单)
        return 1000 //如果是刚处理完订单 ， 等一秒马上在循环
    end
    if(fileexist(C_个别资料夹 & "eread.txt")) // 当前有订单 && !参_处理完订单
        return 2000
    end
    if(发图中)
        return 2000
    end
    //刚处理完
    var 局_CD = filereadini("Refresh", "RefreshTime", C_配置路径)
    if(局_CD == "" || 局_CD == null)
        return 20 * 1000 //如果是当前没订单预设等待5秒
    end
    return cint(局_CD * 1000)
end

function 等待时间(参_时间, 参_讯息)
    for(var i = 0; i < 参_时间 / 1000; i++)
        staticsettext("等待", 参_讯息 & cstring((参_时间 / 1000) - i))
        
        if(C_订单标志)
            wlog("等待時間", "有訂單退出等待，加速" & cstring((参_时间 / 1000) - i) & "秒")
            C_订单标志 = false
            break
        end
        
        
        if(staticgettext("状态") == "目前無訂單，抓取新訂單中") // 重開
            if(FireBase_取待发送状态())
                wlog("等待時間", "Firebase 推播加速" & cstring((参_时间 / 1000) - i) & "秒")
                break
            end
            
            
        end
        if(Firebase_取重启状态())
            逍遥_关闭模拟器(true)
        end
        
        
        
        
        
        if((参_时间 / 1000) - i >= 28)
            if(strfind(网页元素获取("浏览器0", "text", "tag:A&id:copy_p2&index:7"), "複製") > -1) // 
                wlog("等待時間", "異常狀況準備退出")
                sleep(3000)
                呼叫_Center_关闭()
                
            end
        end
        
        if(i == 10)
            threadbegin("bmpToGif", true)
            //bmpToGif(false)
        end
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
    var 局_重开时间差 = 时间间隔("s", now, filereadini("CenterConfig", "LastReStartTime", C_配置路径))
    if(局_重开时间差 > -300 && 局_重开时间差 < 0) //计算五分钟内是否重开过
        return false
    end
    var 局_关闭时间 = strformat("%s/%s/%s %s:00", 时间年(now), 时间月(now), 时间日(now), 局_小时)
    var 局_关闭前5分 = 指定时间("n", -5, 局_关闭时间)
    // traceprint(局_关闭时间)
    // traceprint(局_关闭前5分)
    // traceprint(时间间隔("n",局_关闭时间,now))
    //  traceprint(时间间隔("n",局_关闭前5分,now)) 
    if(时间间隔("n", 局_关闭时间, now) < 0 && 时间间隔("n", 局_关闭前5分, now) > 0)
        traceprint("关闭的时间")  // 如果在關閉時間而且讀取出來又是Restart的話關閉模擬器並自我退出
        return true
    end
end

function 检测订单超时()
    if(!C_订单发送时间)
        return null
    end
    var 局_超时 = 时间间隔("s", C_订单发送时间, 当前时间())
    
    if(局_超时 > 40)
        wlog("檢測訂單超時", "目前訂單已經發送" & 时间间隔("s", C_订单发送时间, 当前时间()) & "秒")
        if(局_超时 >= 60 && 局_超时% 5 == 0)
            var now = timenow()
            var log_path = C_Noxshare & C_帐密[0] & strformat("\\log\\%s-%s-%s_1.log", 时间年(now), 时间月(now),时间日(now))
            var line_count = 文件获取行数(log_path)
            var last_line = 文件读指定行(log_path,line_count-1)
            if(strfind(last_line, "Too many open files") > -1)
                wlog("检测订单超时","模擬器Robot 遇到異常崩潰")
                呼叫_Center_关闭()
            end
        end
        
    end
    
    if(局_超时 > 180)
        
        wlog("檢測訂單超時", "訂單發送後超過3分鐘沒發圖，請察看機器是否異常 test")
        异常推播("訂單發送後超過3分鐘沒發圖，請察看機器是否異常" & 转字符型(C_订单发送时间))
        // filewriteex(C_个别资料夹 & "\\apkver.txt", 1)
        // sleep(30 * 1000)
        逍遥_关闭模拟器()
        呼叫_Center_关闭()
        //启动停止_点击()
    end
end

function 关闭模拟器()
    var 局_讯号 = filereadex(C_个别资料夹 & "isRestart.txt")
    traceprint(局_讯号)
    if(局_讯号 == "ReStart")
        逍遥_关闭模拟器(true)
    end
end