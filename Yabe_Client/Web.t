function Web_取VPN权限()
    wlog("Web_取VPN權限","準備獲取Vpn權限",false)
    变量 header = 数组(),局_结果
    header["Accept"] = "*/*"
    header["User-Agent"] = "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:17.0) Gecko/17.0 Firefox/17.0"
    header["Accept-Language"] = "zh-CN,en-US;q=0.5"
    header["Accept-Encoding"] = "deflate"
    header["Cache-Control"] = "no-cache"
    var 局_记录时间 = 获取系统时间()
    //局_结果 = http提交请求("get","http://ok963963ok.synology.me/Yabe/YabeVpn2.php?Device="& C_帐密[0] &"&OnOff=True","","utf-8",header,"",true,3000)
    局_结果 = http提交请求("get","http://www.iyabetech.com/Yabe/YabeVpn2.php?Device="& C_帐密[0] &"&OnOff=True","","utf-8",header,"",true,3000)
    if(获取系统时间()-局_记录时间 > 5000)
        wlog("Web_取VPN權限","獲取權限超過5秒，可能超時",false)
    end
    wlog("Web_取VPN權限","獲取Vpn權限結果: " & 局_结果,false)
    //traceprint("http://ok963963ok.synology.me/Yabe/YabeVpn.php?Device="& C_帐密[0] &"&OnOff=True")
    if(strfind(局_结果,"Fail") > -1)
        filewriteini("VPN",C_帐密[0],"",C_配置路径)
        wlog("Web_取VPN權限","系統不給予VPN權限",true)
        return false
    else
        staticsettext("状态","")//取得權限就清空狀態顯示
        wlog("Web_取VPN權限","系統給予VPN權限",true)
        filewriteini("VPN",C_帐密[0],"√",C_配置路径)
        return true
    end
    
end

function Web_置VPN解锁()
    变量 header = 数组(),局_结果
    header["Accept"] = "*/*"
    header["User-Agent"] = "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:17.0) Gecko/17.0 Firefox/17.0"
    header["Accept-Language"] = "zh-CN,en-US;q=0.5"
    header["Accept-Encoding"] = "deflate"
    header["Cache-Control"] = "no-cache"
    //局_结果 = http提交请求("get","http://ok963963ok.synology.me/Yabe/YabeVpn2.php?Device="& C_帐密[0] &"&OnOff=false","","utf-8",header,"",true,3000)
    局_结果 = http提交请求("get","http://www.iyabetech.com/Yabe/YabeVpn2.php?Device="& C_帐密[0] &"&OnOff=false","","utf-8",header,"",true,3000)
    filewriteini("VPN",C_帐密[0],"",C_配置路径)
    //traceprint("http://ok963963ok.synology.me/Yabe/YabeVpn.php?Device="& C_帐密[0] &"&OnOff=True")
    // traceprint(局_结果)
    if(strfind(局_结果,"Fail") > -1)
        return false
    else
        return true
    end
    
end



function Web_取订单资料(参_国家)
    if(参_国家 != "臺灣") // 不等於臺灣必須先取得VPN權限
        var 局_贴图权限 = Web_取VPN权限()
        if(局_贴图权限)// 有權限直接取國外的
            wlog("Web_取訂單資料","取得權限準備取" & 参_国家,false)
            return Web_取订单资料_单纯取资料(参_国家)
        end
        while(!局_贴图权限)
            
            if(局_贴图权限)
                wlog("Web_取訂單資料","循環取得權限準備取" & 参_国家,false)
                return Web_取订单资料_单纯取资料(参_国家)
            else
                if(arrayfindkey(C_待送国家,"臺灣")>-1)
                    staticsettext("状态","有國外訂單，但無VPN權限，改發台灣單")
                    sleep(3000)
                    return Web_取订单资料_单纯取资料("臺灣")
                else
                    Sys_置讯息(参_国家 & "有國外訂單，等待VPN權限",true)
                    if(strfind(Web_取待送国家("Web_取訂單資料"),"臺灣")>-1)
                        staticsettext("状态","有國外訂單，但無VPN權限，改發台灣單")
                        wlog("Web_取訂單資料","有國外訂單，但無VPN權限，改發台灣單")
                        sleep(3000)
                        return Web_取订单资料_单纯取资料("臺灣")
                    end
                    等待时间(filereadini("CenterConfig","VPNdelay",C_配置路径)*1000,"等待")
                    局_贴图权限 = Web_取VPN权限() //重新取一次權限
                    
                end          
            end
        end
    end
    return Web_取订单资料_单纯取资料(参_国家) //取臺灣的
end

function Web_取订单资料_单纯取资料(参_国家)
    var 局_ID,局_Code,局_记录时间 = 获取系统时间()
    wlog("Web_取訂單資料_單純取資料","準備獲取訂單資訊",false)
    局_Code = http_获取源码(Cw_国家网址[参_国家]) //页面原始码 http获取页面源码(Cw_国家网址[参_国家],"utf-8") 
    wlog("Web_取訂單資料_單純取資料","獲取訂單資訊結束",false)
    if(局_Code)
        webgo("浏览器0",Cw_国家网址[参_国家])
        if(C_调试)
            局_ID = 正则子表达式匹配(局_Code,"<p id=\"para\" style=\"padding:5px 0px 0px 0px;\">([a-zA-Z0-9\\._-]+)",false,true,true)
        else
            局_ID = 正则子表达式匹配(局_Code,"<p id=\"para_2\" style=\"padding:5px 0px 0px 0px;\">([\\x{4e00}-\\x{9fa5}a-zA-Z0-9\\._-]+)",false,true,true)
        end
        var 局_LineWeb = Web_取订单资料_取LineWeb(局_Code)
        var 局_Error = 正则子表达式匹配(局_Code,"<font color=\"red\">【(\\S{0,4})",false,false)
        var 局_价格 = 正则子表达式匹配(局_Code,"<p id=\"Price\" style=\"padding:5px 0px 0px 0px;\">(\\d+)",true,true)
        var 局_No = 正则子表达式匹配(局_Code,"id=\"No\" value=\"(\\d+)",true,true)
        var 局_贴图名称 = Web_取订单资料_单纯取资料_贴图名称处理(局_Code)
        var 局_资料=array()
        if(局_ID[0] != null && 局_LineWeb != null && (!fileexist(C_个别资料夹 & "發圖中.txt"))) //(strfind(aa,"已處理") == -1 || aa == "" ) 確保不是再發圖得狀態
            
            for(var i = 0; i < 10 && !Web_比对页面id和网址(局_ID[0],局_LineWeb); i++)
                sleep(500)
                if(i == 9)
                    wlog("Web_取訂單資料_單純取資料","ID或網址不匹配")
                    异常推播("ID或網址不匹配---工程師debug用")
                    return false
                end
                
            end
            arraypush(局_资料,局_ID[0],"ID")
            arraypush(局_资料,"","Message")
            arraypush(局_资料,局_贴图名称,"StkName")
            arraypush(局_资料,局_LineWeb,"LineWeb")
            arraypush(局_资料,参_国家,"Country")
            arraypush(局_资料,"未接收","Status")
            //arraypush(局_资料,C_国家英文[参_国家],"Country")
            arraypush(局_资料,局_Error[0],"Error")//0 無異常 1封鎖異常 2更新異常
            arraypush(局_资料,局_价格["0"],"Price")
            arraypush(局_资料,局_No["0"],"No")
            yes_is已处理_检测已有此图(局_资料)//检测App是否已經發過此圖，可能是上一个回报失败
            Sqlite_写订单(局_资料)
            editsettext("订单资料2"," " & 资讯断行(数组转资讯(局_资料,"Status")))
            
            wlog("Web_取訂單資料_單純取資料","已發送資料給APP端發圖")
            Sys_置讯息("已發送資料給APP端發圖",true)
            Sql写订单(局_ID[0],局_资料)
            C_订单发送时间 = 当前时间()
            sleep(1000)
            return true
        else
            //            if(!fileexist(C_个别资料夹 & "發圖中.txt"))
            //                filedelete("C:\\ErrorRecord.txt")
            //                filewriteex("C:\\ErrorRecord.txt",局_Code)
            //                webgo("浏览器0",Cw_国家网址[参_国家])
            //                sleep(2000)
            //                异常推播("異常Z-訂單資料無法分析,請人工處理並填工單，請把C:\\ErrorRecord.txt提交給工程師")
            //                Web_点选Boss("異常Z-其他錯誤 - Manual_Handling26","異常無法分析",true)
            //            end
            
            
        end
    end
    if(!局_Code && 获取系统时间() - 局_记录时间 > 25000)
        wlog("Web_取訂單資料_單純取資料","獲取訂單資料超時30秒")
    end
    editsettext("订单资料2","")
    Sys_置讯息("目前無訂單，抓取新訂單中")
    staticsettext("等待","")
    Web_置VPN解锁()
    return false
end

//把Code 丢进来后处理所有贴图名称
function Web_取订单资料_单纯取资料_贴图名称处理(参_网页码)
    var 局_结果 = 正则子表达式匹配(参_网页码,"</span>(.+)",true,true)
    if(arraysize(局_结果) >= 3)
        for(var i = 0; i < arraysize(局_结果); i++)
            if(strfind(局_结果[i],"/a") == -1 && strfind(局_结果[i],"/div") == -1)
                var 局_result = strreplace(局_结果[i]," ","")
                局_result = strreplace(局_result,"&","")
                局_result = strreplace(局_result,";","")
                局_result = strreplace(局_result,"\"","")
                局_result = strreplace(局_result,"#39","")
                return 局_result
            end
        end
    end
    return ""
end

function Web_中国回报(参_国家)
    if(参_国家 == "中國")
        wlog("Web_中國回報","中國訂單直接回報")
        webgo("浏览器0",Cw_国家网址[参_国家])
        sleep(1000)
        for(var i = 0; i < 15; i++)
            staticsettext("状态","發圖結果回報網站")
            wlog("Web_中國回報","進入回報網頁第" & i & "次",false)
            var s = "var a = $(\"[id=Name]\"); return a[1].value;"
            if(网页执行js("浏览器0",s)!="")
                break
            end
            sleep(1000)
        end
        Web_点选Boss("異常9-中國封鎖LINE - Error9") //写回报后会把Order.txt净空
        return true
    end
    return false
end

function Web_取订单资料_取LineWeb(参_Code)
    var 局_Web数组 = 正则表达式匹配(参_Code,"line://shop/\\S+",false,true)
    for(var i = 0; i < arraysize(局_Web数组); i++)
        var str = 局_Web数组[i]
        if(strfind(str,"1276714") == -1 && strfind(str,"　")==-1)
            str = strreplace(str,"\"","")
            str = strreplace(str,">","")
            traceprint(str)
            return str
        end
    end
    return null
end

function Web_取待送国家(参_讯息="") //取有多少資料可以送
    wlog("Web_取待送國家","呼叫函數為" & 参_讯息,false)
    wlog("Web_取待送國家","準備獲取待送國家",false)
    var 局_页面 = http_获取源码(C_YabeWeb & "Member2.php") //http获取页面源码(C_YabeWeb & "Member2.php","utf-8")
    wlog("Web_取待送國家","獲取待送國家完成",false)
    filewriteex("A:\\123.txt",局_页面)
    if(strfind(局_页面,"發完") > -1 || fileexist(C_个别资料夹 & "發圖中.txt")) // 已經發完網站無訂單，
        Web_取待送国家_是否发完(局_页面)
        return ""
    elseif(strfind(局_页面,"登入會員")> -1 || strfind(局_页面,"404")> -1)// 已经被登出了
        wlog("Web_取待送國家","網站異常登出,或者瞬斷404")
        //异常推播("網站異常登出,或者瞬斷404")
        Sys_错误停止(C_帐密[0] & "網站異常登出,或者瞬斷404")
        退出()
        return ""
    elseif(局_页面 == null)
        wlog("Web_取待送國家","目前無待送國家")
        return ""
    end
    var 局_数量 = 正则子表达式匹配(局_页面,"<td><span class=\"markText13 \">(\\d+)",false,true)
    var 局_国家 = 正则子表达式匹配(局_页面,"<td><span class=\"markText13 markRed\">【(\\W{6})",false,true)
    Web_取待送国家_整理国家(局_国家)
    var 局_讯息 = ""
    arrayclear(C_待送国家)
    for(var i = 0; i < arraysize(局_数量); i++)
        if(局_国家[i] == "國外")
            异常推播("出現異常國家「國外」")
            continue
        end
        if(arrayfindkey(Cw_国家网址,局_国家[i]) > -1)
            局_讯息 = 局_讯息 & 局_国家[i] & ":" & 局_数量[i] & " "
            arraypush(C_待送国家,局_数量[i],局_国家[i])
        else
            wlog("Web_取待送國家","取得異常國家名稱:" & 局_国家[i])
        end
        
    end
    wlog("Web_取待送國家","國家列表為:" & 局_讯息,false)
    文件写配置("待發",C_帐密[0],局_讯息,C_配置路径)
    
    return 局_讯息
end

function Web_取待送国家_是否发完(参_网页码)
    if(strfind(参_网页码,"發完")>-1 )
        arrayclear(C_待送国家)
        Web_取待送国家_其他待发(参_网页码)
        文件写配置("待發",C_帐密[0],"",C_配置路径)
        wlog("Web_取待送國家","目前無訂單，抓取新訂單中")
        editsettext("订单资料2","")
        yes_订单数量检测()
        Sys_置讯息("目前無訂單，抓取新訂單中",true)
        staticsettext("等待","")
        Web_置VPN解锁()
    end
end

//判断是否其他手机有待发
function Web_取待送国家_其他待发(参_网页码)
    var 局_value,局_key
    var 局_成果 = 正则子表达式匹配(参_网页码,"class=\"markText13 \">(\\w+)",true,true)  
    if(arraysize(局_成果) > 0)
        for(var i = 0; i < arraysize(局_成果); i++)
            arraygetat(局_成果,i,局_value,局_key)
            if(strfind(局_value,"march") > -1 || strfind(局_value,"yabe") > -1)
                窗口发送消息(窗口查找(局_value),5000,5000,5000)
            end
            
        end
    end
    //正则子表达式匹配(局_Code,"<p id=\"para_2\" style=\"padding:5px 0px 0px 0px;\">([\\x{4e00}-\\x{9fa5}a-zA-Z0-9\\._-]+)",false,true,true)
end

function Web_取待送国家_整理国家(&参_国家)
    for(var i = 0; i < arraysize(参_国家); i++)
        参_国家[i] = 字符串截取(参_国家[i],0,strfind(参_国家[i],"貼圖"))
    end
end

function Web_is回报完成(参_讯息)
    wlog("Web_is回報完成","準備獲取回報結果",false)
    
    //var 局_最后回报 = http提交请求("get",C_网域 & "LastStatus.php?Device=" & C_帐密[0] & "&No=" & 参_讯息["No"],"","utf-8",null,"",true,8000)//http获取页面源码(C_网域 & "LastStatus.php?Device=" & C_帐密[0],"utf-8")
    var 局_最后回报 = http获取页面源码(C_网域 & "LastStatus.php?Device=" & C_帐密[0] & "&No=" & 参_讯息["No"],"utf-8")//http获取页面源码(C_网域 & "LastStatus.php?Device=" & C_帐密[0],"utf-8")
    wlog("Web_is回報完成","準備獲取回報結果結束",false)
    for(var i = 0; i < 3 && !isarray(json转数组(局_最后回报)); i++)
        wlog("Web_is回報完成","查詢網站最後訂單失敗,準備兩秒後重試")
        wlog("Web_is回報完成","網站查詢資料結果:" & 局_最后回报,false)
        sleep(2000)
        局_最后回报 = http获取页面源码(C_网域 & "LastStatus.php?Device=" & C_帐密[0] & "&No=" & 参_讯息["No"],"utf-8") //http获取页面源码(C_网域 & "LastStatus.php?Device=" & C_帐密[0],"utf-8")
    end
    var 局_数组 = json转数组(局_最后回报)
    if(!isarray(局_数组))
        wlog("Web_is回報完成","查詢網站最後訂單失敗 資料:" & 局_最后回报)
        异常推播("網站最後一筆登入訂單查詢異常,查詢結果:" & 局_最后回报)
        messagebox("網站最後一筆登入訂單查詢異常,查詢結果:" & 局_最后回报,C_帐密[0])
        启动停止_点击()
    end
    局_数组[0]["herf"] = url解码(局_数组[0]["herf"],"utf-8")
    局_数组[0]["Line_ID"] = url解码(局_数组[0]["Line_ID"],"utf-8")
    if(参_讯息 != "")
        if(!isarray(参_讯息))
            messagebox("異常不是陣列類型" & 参_讯息,C_帐密[0] & "錯誤")
            return false
        end
    end
    
    if(参_讯息["ID"] != 局_数组[0]["Line_ID"] || 局_数组[0]["herf"] != 参_讯息["LineWeb"] || strfind(参_讯息["Message"],局_数组[0]["Buy_Status"]) == -1)
        wlog("Web_is回報完成" ,"最後一筆資料與回報資料不符合,詳細資料請看日誌")
        wlog("Web_is回報完成","回報資料應為:")
        wlog("Web_is回報完成",数组转资讯(参_讯息))
        wlog("Web_is回報完成","============")
        wlog("Web_is回報完成","實際資料:" )
        wlog("Web_is回報完成",数组转资讯(局_数组))
        return false
    end
    return true
end

function Web_比对页面id和网址(参_ID,参_网址)
    var web = "var a = $(\"[id=Name]\"); return a[1].value;"
    var id = "var a = document.getElementsByName(\"Line_ID\");return a[1].value;"
    wlog("Web_比對頁面id和網址",strformat("原本ID:%s 原本網址%s 網頁ID:%s 網頁網址:%s",参_ID,参_网址,网页执行js("浏览器0",id),网页执行js("浏览器0",web)),false)
    if(网页执行js("浏览器0",web) == 参_网址 && 网页执行js("浏览器0",id) == 参_ID)
        return true
    end
    return false
end

function Sql写订单(参_ID,参_讯息)
    init_SqlPath()
    var 局_数组 = array()
    sqlitesqlarray(C_DB_Path,strformat("insert into log (id,訂單資料,接收時間) values ('%s','%s',datetime('now','localtime'))",参_ID,数组转资讯(参_讯息,"Status")),局_数组)
end

function Sql写回报(参_ID,参_讯息,参_备注="")
    var 局_数组 = array()
    //设置剪切板(strformat("Update `log` set id='%s',處理結果='%s',處理時間=datetime('now','localtime'),備註='%s' where id='%s' and 處理結果 is null and 處理時間 is null",参_ID,参_讯息,参_备注,参_ID))
    sqlitesqlarray(C_DB_Path,strformat("Update `log` set id='%s',處理結果='%s',處理時間=datetime('now','localtime'),備註='%s' where id='%s' and 處理結果 is null and 處理時間 is null",参_ID,参_讯息,参_备注,参_ID),局_数组)
end

function Sqlite_读订单()
    var 局_数组 = array(),局_资讯分割 = array()
    if(!fileexist(C_个别资料夹 & "cread.txt"))
        traceprint("無權限讀取訂單" & timenow())
        return "無權限" //有單
    end
    if(sqlitesqlarray(C_DB_OrderPath,"SELECT Data FROM `OrderData`",局_数组))
        if(arraysize(局_数组)>0 && 局_数组!=null)
            var 局_结果 = 局_数组[0]["Data"]
            if(局_数组[0]["Data"] == "")
                return ""
            end
            strsplit(局_数组[0]["Data"]," | ",局_资讯分割)
            return Sqlite_内部资讯分割(局_资讯分割)
        end
    end
    return ""
end

function Sqlite_内部资讯分割(参_数组)
    var 局_暂存分割 = array(),局_返回分割 = array()
    
    for(var i = 0; i < arraysize(参_数组); i++)
        if(参_数组[i] == "")
            break
        end
        if(strsplit(参_数组[i],"：",局_暂存分割))
            arraypush(局_返回分割,局_暂存分割[1],局_暂存分割[0])
        end
    end
    return 局_返回分割
end

function Sqlite_写订单(参_Data)
    var 局_数组 = array(),局_写入=""
    if(isarray(参_Data))
        局_写入 = 数组转资讯(参_Data)
    else
        局_写入 = 参_Data
    end
    if(局_写入 != "")
        if(sqlitesqlarray(C_DB_OrderPath,"SELECT COUNT() FROM [OrderData] LIMIT 500",局_数组))
            if(局_数组[0]["COUNT()"] == 0)
                sqlitesqlarray(C_DB_OrderPath,"Insert into `OrderData` (Data) values ('"& 局_写入 &"')",局_数组)
                return ""
            end
        end
    end
    
    if(sqlitesqlarray(C_DB_OrderPath,"Update `OrderData` Set Data='" & 局_写入 & "'",局_数组))
        if(局_写入 != "")
            wlog("Sqlite_寫訂單","準備開放權限給App",false)
            Sqlite_开放权限() //开放权限给 app读取
            wlog("Sqlite_寫訂單","權限開放結果" & fileexist(C_个别资料夹 & "eread.txt"),false)
        end
        return true
        
    end
    return ""
end

function Sqlite_开放权限()
    for(var i = 0; i < 10; i++)
        var 局_句柄 = 文件创建(C_个别资料夹 & "eread.txt","CREATE_ALWAYS")
        sleep(200)
        if(fileexist(C_个别资料夹 & "eread.txt"))
            wlog("Sqlite_開放權限","開放權限成功",false)
            文件关闭(局_句柄)
            return true
        end
        sleep(100)
    end
    if(!fileexist(C_个别资料夹 & "eread.txt"))
        wlog("Sqlite_開放權限","開放權限失敗，等待程序自動排除",true)
    end
    
    return false
end

function Sqlite_24小时订单处理() //处理24小时以前订单发送记录
    var 局_路径 = C_个别资料夹 & C_帐密["0"] & ".db",局_修改数量 = array()
    sqlitesqlarray(局_路径,"Delete from [log] where [處理時間] between datetime(datetime('now', 'localtime'),'-60 days') and datetime(datetime('now', 'localtime'),'-24 hour')",局_修改数量)
    if(arraysize(局_修改数量)>0)
        wlog("Sqlite_24小时订单处理","刪除過去24小時前訂單:" & cstring(arraysize(局_修改数量)))
    end
end

function 数组转资讯(参_数组,参_过滤="",参_过滤空值=false)
    var 局_讯息 = "",局_Value,局_Key
    for(var i = 0; i < arraysize(参_数组); i++)
        arraygetat(参_数组,i,局_Value,局_Key)
        if(参_过滤空值 && (局_Value == "" || 局_Value == false)) //過濾空值
            continue
        end
        if(strfind(参_过滤,局_Key) == -1)
            局_讯息 = 局_讯息 & 局_Key & "：" & 局_Value & " | "
        end
    end
    return 局_讯息
end

function 数组转资讯推播整理(参_数组,参_过滤="",参_过滤空值=false)
    var 局_讯息 = "",局_Value,局_Key
    for(var i = 0; i < arraysize(参_数组); i++)
        arraygetat(参_数组,i,局_Value,局_Key)
        if(参_过滤空值 && (局_Value == "" || 局_Value == null)) //過濾空值
            continue
        end
        if(strfind(参_过滤,局_Key) == -1)
            if(局_Key == "LineWeb")
                var 局_网站编号 = strsub(参_数组["StkName"],0,strfind(参_数组["StkName"],"-"))
                局_讯息 =  局_讯息 & "http://yabeline.tw/Stickers_Search.php?Search=" & 局_网站编号 & " | " 
                
                局_讯息 =  局_讯息 & 局_Key & "：" & 局_Value & " | " 
                if(strfind(参_数组["StkName"],"theme") == -1)
                    局_讯息 =  局_讯息 & "http://yabeline.tw/Admin_Stickers_Edit.php?Number=" & 局_网站编号 & "%26Type=1"  & " | "  & " | "
                else
                    局_讯息 =  局_讯息 & "http://yabeline.tw/Admin_Stickers_Edit.php?Number=" & 局_网站编号 & "%26Type=2"  & " | "  & " | "
                end
            elseif(局_Key == "ID")
                局_讯息 =  局_讯息 & 局_Key & "：" & 局_Value & " | " & "http://yabeline.tw/Admin_User.php?Line_ID=" & 局_Value & " | "
                
            else
                局_讯息 = 局_讯息 & 局_Key & "：" & 局_Value & " | "
            end
            
        end
    end
    局_讯息 = strreplace(局_讯息,"ID：","")
    局_讯息 = strreplace(局_讯息,"LineWeb：","")
    局_讯息 = strreplace(局_讯息,"StkName：","")
    //    局_讯息 = strreplace(局_讯息,"Country：","")
    局_讯息 = strreplace(局_讯息,"Message：","")
    return 局_讯息
end

function 资讯断行(参_字串,参_url编码=false)
    var 局_数组 = array(),局_讯息=""
    参_字串 = 参_字串 & " " & 参_字串
    for(var i = 0; i < strsplit(参_字串,"|",局_数组); i++)
        局_讯息 = 局_讯息 & 局_数组[i] & "\r\n"
    end
    if(参_url编码)
        return url编码(局_讯息)
    else
        return 局_讯息
    end
    
end


