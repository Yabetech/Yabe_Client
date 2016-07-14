function Web_取VPN权限()
    变量 header = 数组(),局_结果
    header["Accept"] = "*/*"
    header["User-Agent"] = "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:17.0) Gecko/17.0 Firefox/17.0"
    header["Accept-Language"] = "zh-CN,en-US;q=0.5"
    header["Accept-Encoding"] = "deflate"
    header["Cache-Control"] = "no-cache"
    局_结果 = http提交请求("get","http://ok963963ok.synology.me/Yabe/YabeVpn.php?Device="& C_帐密[0] &"&OnOff=True","","utf-8",header)
    //traceprint("http://ok963963ok.synology.me/Yabe/YabeVpn.php?Device="& C_帐密[0] &"&OnOff=True")
    traceprint(局_结果)
    if(strfind(局_结果,"Fail") > -1)
        return false
    else
        staticsettext("状态","")//取得權限就清空狀態顯示
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
    局_结果 = http提交请求("get","http://ok963963ok.synology.me/Yabe/YabeVpn.php?Device="& C_帐密[0] &"&OnOff=false","","utf-8",header)
    //traceprint("http://ok963963ok.synology.me/Yabe/YabeVpn.php?Device="& C_帐密[0] &"&OnOff=True")
    traceprint(局_结果)
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
        if(Web_取VPN权限())
            Web_取订单资料_单纯取资料(参_国家)
        else
            if(arrayfindkey(C_待送国家,"臺灣")>-1)
                staticsettext("状态","等待VPN權限(先發臺灣單)")
                Web_取订单资料_单纯取资料("臺灣")
                return true
            else
                staticsettext("状态","等待VPN權限(無臺灣單)")
                sleep(5000)
                return false
            end          
        end
        
    end
    return Web_取订单资料_单纯取资料(参_国家)
end

function Web_取订单资料_单纯取资料(参_国家)
    var 局_Code = http获取页面源码(Cw_国家网址[参_国家],"utf-8") //页面原始码
    //设置剪切板(局_Code)
    var 局_ID = 正则子表达式匹配(局_Code,"<p id=\"para\" style=\"padding:5px 0px 0px 0px;\">([a-zA-Z0-9\\._]+)",false,true)
    //var 局_LineWeb = 正则子表达式匹配(局_Code,"id=\"Name\" value=\"([^ 　\\r\\t\\n\\f]+)",true,true)
    var 局_LineWeb =Web_取订单资料_取LineWeb(局_Code)
    //var 局_LineWeb = 正则子表达式匹配(局_Code,"id=\"Name\" value=\"([^ 　\\r\\t\\n\\f]+)",true,true)
    var 局_Error = 正则子表达式匹配(局_Code,"<font color=\"red\">【(\\S{0,4})",false,false)
    var 局_价格 = 正则子表达式匹配(局_Code,"<p id=\"Price\" style=\"padding:5px 0px 0px 0px;\">(\\d+)",true,true)
    traceprint(strformat("局_ID:%s 局_LineWeb:%s",局_ID,局_LineWeb))
    var 局_资料=array()
    var aa = 读文档()
    traceprint(aa)
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
        文件覆盖内容(Cy_OrderPath,局_资料,2)
        staticsettext("订单资料",数组转资讯(局_资料))
        Sql写订单(局_ID[0],局_资料)
        return true
    end
    staticsettext("订单资料","")//清空顯示狀態
    Web_置VPN解锁()
    return false
end

function Web_中国回报(参_国家)
    if(参_国家 == "中國")
        webgo("浏览器0",Cw_国家网址[参_国家])
        sleep(1000)
        
        for(var i = 0; i < 15; i++)
            
            staticsettext("状态","跳轉網頁" & cstring(i))
            traceprint(网页元素获取("浏览器0","value","name:Line_ID"))
            if(网页元素获取("浏览器0","value","name:Line_ID")!="")
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
    var tt = http获取页面源码("http://deve.yabeline.tw/Member2.php","utf-8")
    if(strfind(tt,"發完")>-1 || 读文档() != "")
        if(strfind(tt,"發完")>-1 )
            文件写配置("待發",C_帐密[0],"無訂單",C_配置路径)
            staticsettext("订单资料","")//清空顯示狀態
            staticsettext("状态","")//清空顯示狀態
            Web_置VPN解锁()
        end
        
        return 
    elseif(strfind(tt,"登入會員")> -1 )// 已经被登出了
        Sys_错误停止("網站異常登出")
        return false
    end
    var 局_数量 = 正则子表达式匹配(tt,"<td><span class=\"markText13 \">(\\d+)",false,true)
    var 局_国家 = 正则子表达式匹配(tt,"<td><span class=\"markText13 markRed\">【(\\W{6})",false,true)
    Web_取待送国家_整理国家(局_国家)
    var 局_讯息
    arrayclear(C_待送国家)
    for(var i = 0; i < arraysize(局_数量); i++)
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

function Sql写订单(参_ID,参_讯息)
    var 局_数组 = array()
    sqlitesqlarray(C_DB_Path,strformat("insert into log (id,訂單資料,接收時間) values ('%s','%s',datetime('now','localtime'))",参_ID,参_讯息),局_数组)
end

function Sql写回报(参_ID,参_讯息,参_备注="")
    var 局_数组 = array()
    设置剪切板(strformat("Update `log` set id='%s',處理結果='%s',處理時間=datetime('now','localtime'),備註='%s' where id='%s' and 處理結果 is null and 處理時間 is null",参_ID,参_讯息,参_备注,参_ID))
    sqlitesqlarray(C_DB_Path,strformat("Update `log` set id='%s',處理結果='%s',處理時間=datetime('now','localtime'),備註='%s' where id='%s' and 處理結果 is null and 處理時間 is null",参_ID,参_讯息,参_备注,参_ID),局_数组)
end

function 数组转资讯(参_数组)
    var 局_讯息 = "",局_Value,局_Key
    for(var i = 0; i < arraysize(参_数组); i++)
        arraygetat(参_数组,i,局_Value,局_Key)
        局_讯息 = 局_讯息 & 局_Key & "：" & 局_Value & " | "
    end
    return 局_讯息
end


