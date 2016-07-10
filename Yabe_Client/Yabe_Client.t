var C_帐密 = array()
var C_国家
var C_调试 = true
var C_Web = "http://deve.yabeline.tw/Member2.php"
var 主线程

var C_Noxshare
功能 Yabe_Client_初始化()
    
    var 局_开始 = false
    var 局_参数 = 获取参数ex()
    if(arraysize(局_参数)>1)
        C_帐密[0] = 局_参数[1]
        C_帐密[1] = 局_参数[2]
        C_帐密["id"] = 局_参数[3]
        窗口最小化(窗口获取自我句柄())
        局_开始 = true
    else
        C_帐密[0] = "march911"
        C_帐密[1] = "123"
        C_帐密["id"] = 3
    end
    if(!C_调试)
        C_Web = "http://yabeline.tw/Member2.php"
    end
    
    threadbegin("自动登入",局_开始)
    init_Main()
    
    //BBY_Reg()
    
结束

function 读文档()
    if(!fileexist(Cy_OrderPath))
        文件覆盖内容(Cy_OrderPath,"",2)
    end
    var a = com("MSL.File")
    
    var aa = a.ReadAllTextUTF8(Cy_OrderPath)
    return aa
end

function Sys_错误停止(参_错误)
    filewriteini("Action",C_帐密[0],"停止:" & 参_错误,C_配置路径)
end

function 自动登入(参_开始=false)
    while(true)
        
        webgo("浏览器0",C_Web)
        while(!网页加载("浏览器0"))
            sleep(100)
        end
        网页元素输入("浏览器0",C_帐密[0],"name:Line_ID")
        网页元素输入("浏览器0", C_帐密[1],"name:password")
        网页元素点击("浏览器0","class:btn btn-success")
        
        for(var i = 0; i < 10; i++)
            sleep(1000)
            if(strfind(网页元素获取("浏览器0","class","tag:BUTTON&index:1"),"btn-default")>-1)
                if(参_开始)
                    启动停止_点击()
                end
                return false
            end
        end
        
    end
    
end

function BBY_Reg()
    var ret = reg("ok963963ok","d74c724b4e8b90810f57e466121453d8") 
    if(ret != 0) 
        messagebox(translateerr(ret)) 
        return 
    end
    var retbuff 
    ret = login("march911", "123",retbuff) 
    if(ret != 0) 
        messagebox(translateerr(ret),"通讯失败") 
    else
        //messagebox(retbuff) 
        BBY_置回调()
    end
end

function BBY_置回调()
    //这里注意回调函数原型,bby_callback 与 bby_callbackex 两种类型需要在tc5.6以后才能使用,5.6以前版本请使用enumwindowsproc(对应bby_callback) 与 hookproc(对应bby_callbackex)
    var callback_handle = callbackmalloc("bby_callbackloginW","bby_callback") //这里注意回调函数原型 
    if(callback_handle !=0) 
        msgcallback_loginW(callback_handle) //此类回调函数只能设置一个,如果设置多个,后面回调会覆盖前面的回调函数 
        traceprint("设置回调函数成功") 
    end
end

//登陆成功后,响应云消息的回调函数,一个进程只能设置一个 
function bby_callbackloginW(type,arg) 
    var content = addressvalue(arg,"wchar *") 
    traceprint(content) 
    if(strfind(content,"Boss") > -1)
        Web_点选Boss(content)
    end
end

function Web_点选Boss(content,参_讯息="")
    
    if(网页元素选择("浏览器0",content,"tag:SELECT&name:Status&index:0"))
        
        if(C_调试)
            messagebox("Boss",C_帐密[0])
        end
        网页元素点击("浏览器0","tag:INPUT&value:Boss")
        //todo 要等頁面跳轉完
        文件覆盖内容(Cy_OrderPath,"",2)
        if(isarray(参_讯息))
            Sql写回报(参_讯息["id"],content,参_讯息["Remark"])
        end
    end
    sleep(5000)
end

function Web_资料符合() //订单资料 和 页面资料是否符合
    var 局_网址 = 网页获取超链接("浏览器0")
    var 局_贴图网址 =  Web_取订单资料_取LineWeb(http获取页面源码(局_网址,"utf-8"))
    var 局_数组资料=array(),局_贴图网址2,局_资料 = 读文档()
    局_数组资料 = stringtoarray(局_资料)
    var 局_ID = 网页元素获取("浏览器0","value","tag:INPUT&name:Line_ID&type:text&index:2")
    // var 局_贴图网址 = 网页元素获取("浏览器0","value","tag:INPUT&index:8") 
    var 局_异常状况 = 网页元素获取("浏览器0","text","tag:FONT&index:2")
    局_异常状况 = strreplace(局_异常状况,"【","")
    局_异常状况 = strreplace(局_异常状况,"】","")
    
    //strsplit(局_贴图网址,"　",局_贴图网址2)
    // traceprint(局_ID != 局_数组资料["ID"])
    // traceprint(局_贴图网址2["0"] != 局_数组资料["LineWeb"] )
    //traceprint(局_异常状况 != 局_数组资料["Error"])
    //traceprint(局_数组资料["Error"] == null)
    if(局_ID != 局_数组资料["ID"] || 局_贴图网址 != 局_数组资料["LineWeb"])
        Sys_错误停止("訂單資料與網頁上不符合")
        return false
    end
    return true
end



function 获取页面资讯()
    
    var 局_贴图网址2
    var 局_ID = 网页元素获取("浏览器0","text","id:para_2")
    var 局_贴图网址 = 网页元素获取("浏览器0","value","tag:INPUT&index:8") //"Name"
    var 局_异常状况 = 网页元素获取("浏览器0","text","tag:FONT&index:2")
    局_异常状况 = strreplace(局_异常状况,"【","")
    局_异常状况 = strreplace(局_异常状况,"】","")
    
    strsplit(局_贴图网址,"　",局_贴图网址2)
    BBY_回报贴图资讯(C_帐密[0],局_ID,局_贴图网址2[0],C_国家,局_异常状况,true)
    
end

function BBY_回报贴图资讯(参_Login,参_ID,参_Web,参_Country,参_Error,参_显示 = false)
    var 局_资料=array()
    arraypush(局_资料,参_Login,"Login")
    arraypush(局_资料,参_ID,"ID")
    arraypush(局_资料,参_Web,"LineWeb")
    arraypush(局_资料,参_Country,"Country")
    arraypush(局_资料,参_Error,"Error")
    var token = "d74c724b4e8b90810f57e466121453d8"
    var params = "token="& token &"&funparams=march911|" & arraytostring(局_资料)
    var url = "http://get.baibaoyun.com/cloudapi/cloudappapi"
    var ret = httpsubmit("GET",url&"?"&params,"","utf-8")
    if(参_显示)
        messagebox(ret)
    end   
    
end


功能 按钮0_点击()
    Auto_SetLineId("Auto")
结束




功能 按钮1_点击()
    //这里添加你要执行的代码
    //    变量 header = 数组()
    //    header["Accept"] = "*/*"
    //    header["User-Agent"] = "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:17.0) Gecko/17.0 Firefox/17.0"
    //    header["Accept-Language"] = "zh-CN,en-US;q=0.5"
    //    header["Accept-Encoding"] = "deflate"
    //    header["Cache-Control"] = "no-cache"
    //    变量 body = http提交请求("get","http://140.130.20.180/test.php?age=get","","utf-8",header)
    //    traceprint(body)
    Web_取待送国家()
    return
    获取页面资讯()
结束


功能 按钮2_点击()
    Web_取VPN权限()
    return
    //这里添加你要执行的代码
    //traceprint(网页元素选择("浏览器0","補送成功 - Try_again_Ok","tag:SELECT&name:Status&index:0"))
    变量 header = 数组()
    header["Accept"] = "*/*"
    header["User-Agent"] = "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:17.0) Gecko/17.0 Firefox/17.0"
    header["Accept-Language"] = "zh-CN,en-US;q=0.5"
    header["Accept-Encoding"] = "deflate"
    header["Cache-Control"] = "no-cache"
    变量 body = http提交请求("get","http://140.130.20.180/test.php?age=get","","utf-8",header)
    traceprint(body)
    
结束

function 异常推播(参_讯息)
    var 局_讯息 = 窗口获取标题(窗口获取自我句柄()) & "    " & 参_讯息
    变量 header = 数组()
    header["Accept"] = "*/*"
    header["User-Agent"] = "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:17.0) Gecko/17.0 Firefox/17.0"
    header["Accept-Language"] = "zh-CN,en-US;q=0.5"
    header["Accept-Encoding"] = "deflate"
    header["Cache-Control"] = "no-cache"
    变量 body = http提交请求("get","http://ok963963ok.synology.me/Yabe/getError.php?Error="& 局_讯息,"","utf-8",header)
    traceprint(body)
end


功能 Test_点击()
    //这里添加你要执行的代码
    for(var i = 0; i < 8; i++)
        var 局_T =  网页元素获取("浏览器0","text","tag:SPAN&index:" & cstring(i))
        if(strfind(局_T,"貼圖")>-1)
            网页元素点击("浏览器0","tag:SPAN&index:" & cstring(i))
            var 局_贴图 = 字符串截取(局_T,字符串查找(局_T,"貼圖")-2,字符串查找(局_T,"貼圖"))
            C_国家 = 局_贴图
            traceprint(C_国家)
            break
        end
        
    end
结束


功能 IdSelect_选择改变()
    editsettext("ID",combogettext("IdSelect"))
结束


function getCookie(参_帐号,参_密码)
    var token = "e0efc91651d08055ebc578d8359f9d0c"
    var params = "token="& token &"&funparams=" & url编码(arraytostring(array("0"=参_帐号,"1"=参_密码)))
    var url = "http://get.baibaoyun.com/cloudapi/cloudappapi"
    var ret = http提交请求("GET",url&"?"&params,"","utf-8")
    traceprint(ret)
    return ret
end

功能 BBY_TEST_点击()
    
    // threadbegin("yes_is已处理","")
    //主线程 = threadbegin("主线程","")
    //Web_取订单资料("臺灣")
    //    Web_取待送国家()
    //    return
    //设置剪切板(http获取页面源码("http://deve.yabeline.tw/Friend_Stickers_Send.php?Country=ja","utf-8"))
    //messagebox(Web_取待送资料())
    var 局_资料 = array()
    arraypush(局_资料,C_帐密[0],"Login")
    arraypush(局_资料,editgettext("ID"),"ID")
    arraypush(局_资料,editgettext("Web"),"LineWeb")
    arraypush(局_资料,editgettext("Country"),"Country")
    //arraypush(局_资料,C_国家英文[参_国家],"Country")
    arraypush(局_资料,editgettext("Error"),"Error")//0 無異常 1封鎖異常 2更新異常
    arraypush(局_资料,"未接收","Status")
    arraypush(局_资料,editgettext("Price"),"Price")
    arraypush(局_资料,"","Message")
    文件覆盖内容(Cy_OrderPath,局_资料,2)
    //messagebox(BBY_回报贴图资讯(C_帐密[0],editgettext("ID"),editgettext("Web"),editgettext("Country"),editgettext("Error"),true)) //仿造訂單
    // traceprint(Web_取待送国家())
结束




功能 启动停止_点击()
    if(buttongettext("启动停止") == "啟動")
        buttonsettext("启动停止","停止")
        文件覆盖内容(C_运作路径,"Run")
        主线程 = threadbegin("主线程","")
    else
        文件覆盖内容(C_运作路径,"Stop")
        buttonsettext("启动停止","啟動")
        threadclose(主线程)
    end
    
结束


//点击关闭_执行操作
功能 Yabe_Client_关闭()
    threadclose(主线程)
    控件关闭子窗口("Yabe_Client",0)
    退出()
结束



功能 Yabe_Client_销毁()
    //这里添加你要执行的代码
    
    
结束


功能 批量下单_点击()
    if(editgettext("ID") == "")
        messagebox("請填寫ID","")
        return false
    end
    var 局_路径 = 文件对话框(1,"*.txt")
    
    if(局_路径!="")
        threadbegin("AutoReadList",局_路径)
    end
    
结束

