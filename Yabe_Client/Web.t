function Web_取VPN权限()
    变量 header = 数组(),局_结果
    header["Accept"] = "*/*"
    header["User-Agent"] = "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:17.0) Gecko/17.0 Firefox/17.0"
    header["Accept-Language"] = "zh-CN,en-US;q=0.5"
    header["Accept-Encoding"] = "deflate"
    header["Cache-Control"] = "no-cache"
    局_结果 = http提交请求("get","http://ok963963ok.synology.me/Yabe/YabeVpn2.php?Device="& C_帐密[0] &"&OnOff=True","","utf-8",header)
    //traceprint("http://ok963963ok.synology.me/Yabe/YabeVpn.php?Device="& C_帐密[0] &"&OnOff=True")
    if(strfind(局_结果,"Fail") > -1)
        filewriteini("VPN",C_帐密[0],"",C_配置路径)
        return false
    else
        staticsettext("状态","")//取得權限就清空狀態顯示
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
    局_结果 = http提交请求("get","http://ok963963ok.synology.me/Yabe/YabeVpn2.php?Device="& C_帐密[0] &"&OnOff=false","","utf-8",header)
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
    if(Web_中国回报(参_国家)) // 中國直接回報中國異常
        return false
    end
    if(参_国家 != "臺灣") // 不等於臺灣必須先取得VPN權限
        var 局_贴图权限 = Web_取VPN权限()
        while(!局_贴图权限)
            if(局_贴图权限)
                return Web_取订单资料_单纯取资料(参_国家)
            else
                if(arrayfindkey(C_待送国家,"臺灣")>-1)
                    staticsettext("状态","有國外訂單，但無VPN權限，改發台灣單")
                    sleep(3000)
                    Web_取订单资料_单纯取资料("臺灣")
                    return true
                else
                    Sys_置讯息(参_国家 & "有國外訂單，等待VPN權限")
                    staticsettext("状态","有國外訂單，等待VPN權限")
                    等待时间(filereadini("CenterConfig","VPNdelay",C_配置路径)*1000,"等待")
                    if(strfind(Web_取待送国家(),"臺灣")>-1)
                        staticsettext("状态","有國外訂單，但無VPN權限，改發台灣單")
                        sleep(3000)
                        return Web_取订单资料_单纯取资料("臺灣")
                    end
                    局_贴图权限 = Web_取VPN权限() //重新取一次權限
                end          
            end
        end
        
        
    end
    return Web_取订单资料_单纯取资料(参_国家) //取臺灣的
end

function Web_取订单资料_单纯取资料(参_国家)
    var 局_ID,局_Code
    wlog("Web_取訂單資料_單純取資料","準備獲取訂單資訊",false)
    局_Code = http获取页面源码(Cw_国家网址[参_国家],"utf-8") //页面原始码
    
    //var 局_ID = 正则子表达式匹配(局_Code,"<p id=\"para_2\" style=\"padding:5px 0px 0px 0px;\">([a-zA-Z0-9\\._-]+)",false,true) 原本的
    if(C_调试)
        局_ID = 正则子表达式匹配(局_Code,"<p id=\"para\" style=\"padding:5px 0px 0px 0px;\">([a-zA-Z0-9\\._-]+)",false,true,true)
    else
        局_ID = 正则子表达式匹配(局_Code,"<p id=\"para_2\" style=\"padding:5px 0px 0px 0px;\">([\\x{4e00}-\\x{9fa5}a-zA-Z0-9\\._-]+)",false,true,true)
    end
    
    //var 局_LineWeb = 正则子表达式匹配(局_Code,"id=\"Name\" value=\"([^ 　\\r\\t\\n\\f]+)",true,true)
    var 局_LineWeb = Web_取订单资料_取LineWeb(局_Code)
    //var 局_LineWeb = 正则子表达式匹配(局_Code,"id=\"Name\" value=\"([^ 　\\r\\t\\n\\f]+)",true,true)
    var 局_Error = 正则子表达式匹配(局_Code,"<font color=\"red\">【(\\S{0,4})",false,false)
    var 局_价格 = 正则子表达式匹配(局_Code,"<p id=\"Price\" style=\"padding:5px 0px 0px 0px;\">(\\d+)",true,true)
    
    var 局_资料=array()
    var aa = 读文档()
    if(局_ID[0] != null && 局_LineWeb != null && (strfind(aa,"已處理") == -1 || aa == "" ))
        //arraypush(局_资料,C_帐密[0],"Login")
        arraypush(局_资料,局_ID[0],"ID")
        arraypush(局_资料,局_LineWeb,"LineWeb")
        arraypush(局_资料,参_国家,"Country")
        //arraypush(局_资料,C_国家英文[参_国家],"Country")
        arraypush(局_资料,局_Error[0],"Error")//0 無異常 1封鎖異常 2更新異常
        arraypush(局_资料,"未接收","Status")
        arraypush(局_资料,局_价格["0"],"Price")
        arraypush(局_资料,"","Message")
        Sqlite_写订单(局_资料)
        //staticsettext("订单资料",)
        editsettext("订单资料2"," " & 资讯断行(数组转资讯(局_资料,"Status")))
        Sys_置讯息("已發送資料給APP端發圖")
        webgo("浏览器0",Cw_国家网址[参_国家])
        wlog("Web_取訂單資料_單純取資料","已發送資料給APP端發圖")
        staticsettext("状态","已發送資料給APP端發圖")
        Sql写订单(局_ID[0],局_资料)
        C_订单发送时间 = 当前时间()
        return true
    end
    //staticsettext("订单资料","")//清空顯示狀態
    editsettext("订单资料2","")
    Sys_置讯息("目前無訂單，抓取新訂單中")
    staticsettext("等待","")
    //filedelete(C_DB_OrderPath)
    Web_置VPN解锁()
    return false
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

function Web_取待送国家() //取有多少資料可以送
    wlog("Web_取待送國家","準備獲取待送國家",false)
    var tt = http获取页面源码(C_YabeWeb & "Member2.php","utf-8")
    wlog("Web_取待送國家","獲取待送國家完成",false)
    if(strfind(tt,"發完")>-1 || 读文档() != "")
        if(strfind(tt,"發完")>-1 )
            文件写配置("待發",C_帐密[0],"",C_配置路径)
            wlog("Web_取待送國家","目前無訂單，抓取新訂單中")
            //staticsettext("订单资料","")//清空顯示狀態
            editsettext("订单资料2","")
            Sys_置讯息("目前無訂單，抓取新訂單中")
            staticsettext("等待","")
            Web_置VPN解锁()
        end
        return ""
    elseif(strfind(tt,"登入會員")> -1 )// 已经被登出了
        Sys_错误停止(C_帐密[0] & "網站異常登出")
        messagebox("請重開本Client 網站被異常登出","錯誤")
        启动停止_点击()
        return ""
    end
    var 局_数量 = 正则子表达式匹配(tt,"<td><span class=\"markText13 \">(\\d+)",false,true)
    var 局_国家 = 正则子表达式匹配(tt,"<td><span class=\"markText13 markRed\">【(\\W{6})",false,true)
    Web_取待送国家_整理国家(局_国家)
    var 局_讯息
    arrayclear(C_待送国家)
    for(var i = 0; i < arraysize(局_数量); i++)
        if(局_国家[i] == "國外")
            continue
        end
        局_讯息 = 局_讯息 & 局_国家[i] & ":" & 局_数量[i] & " "
        arraypush(C_待送国家,局_数量[i],局_国家[i])
    end
    traceprint("目前待發送國家有" & 局_讯息)
    文件写配置("待發",C_帐密[0],局_讯息,C_配置路径)
    return 局_讯息
end

function Web_取待送国家_整理国家(&参_国家)
    for(var i = 0; i < arraysize(参_国家); i++)
        参_国家[i] = 字符串截取(参_国家[i],0,strfind(参_国家[i],"貼圖"))
    end
end

function Web_is回报完成(参_讯息)
    var 局_最后回报 = http获取页面源码(C_网域 & "LastStatus.php?Device=" & C_帐密[0],"utf-8")
    for(var i = 0; i < 3 && !isarray(json转数组(局_最后回报)); i++)
        wlog("Web_is回報完成","查詢網站最後訂單失敗,準備兩秒後重試")
        wlog("Web_is回報完成","網站查詢資料結果:" & 局_最后回报,false)
        sleep(2000)
        局_最后回报 = http获取页面源码(C_网域 & "LastStatus.php?Device=" & C_帐密[0],"utf-8")
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
    
    if(参_讯息["ID"] != 局_数组[0]["Line_ID"] || 局_数组[0]["herf"] != 参_讯息["LineWeb"])
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
        //局_写入 = aes加密(局_写入,"123")
    else
        局_写入 = 参_Data
    end
    if(局_写入!="")
        if(sqlitesqlarray(C_DB_OrderPath,"SELECT COUNT() FROM [OrderData] LIMIT 500",局_数组))
            if(局_数组[0]["COUNT()"] == 0)
                // 设置剪切板("Insert into `OrderData` (Data) values ('%s')")
                sqlitesqlarray(C_DB_OrderPath,"Insert into `OrderData` (Data) values ('"& 局_写入 &"')",局_数组)
                return ""
            end
        end
    end
    //设置剪切板("Update `OrderData` Set Data='" & 局_写入 & "'")
    if(sqlitesqlarray(C_DB_OrderPath,"Update `OrderData` Set Data='" & 局_写入 & "'",局_数组))
        return true
        
    end
    return ""
end

function 数组转资讯(参_数组,参_过滤="")
    var 局_讯息 = "",局_Value,局_Key
    for(var i = 0; i < arraysize(参_数组); i++)
        arraygetat(参_数组,i,局_Value,局_Key)
        if(strfind(参_过滤,局_Key) == -1)
            局_讯息 = 局_讯息 & 局_Key & "：" & 局_Value & " | "
        end
    end
    return 局_讯息
end

function 资讯断行(参_字串)
    var 局_数组 = array(),局_讯息=""
    参_字串 = 参_字串 & " " & 参_字串
    for(var i = 0; i < strsplit(参_字串,"|",局_数组); i++)
        局_讯息 = 局_讯息 & 局_数组[i] & "\r\n"
    end
    return 局_讯息
end


