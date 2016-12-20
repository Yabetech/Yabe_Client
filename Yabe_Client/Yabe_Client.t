var C_帐密 = array()
var C_国家
var C_Web
var C_网域
var 主线程,监测线程
var C_Noxshare
var C_订单标志=false
var 临时线程句柄,Global_源码开关
功能 Yabe_Client_初始化()
    var 局_开始 = false
    var 局_参数 = 获取参数ex()
    if(arraysize(局_参数)>1)
        C_帐密[0] = 局_参数[1]
        C_帐密[1] = 局_参数[2]
        C_帐密["id"] = 局_参数[3]
        
        if(局_参数[3]<=3)
            窗口设置位置(窗口获取自我句柄(),(局_参数[3]-1)*480,538)
            
        else //發圖機的環境
            窗口设置位置(窗口获取自我句柄(),(局_参数[3]-2)*480,538)
        end
        局_开始 = true
    else
        C_帐密[0] = "yabeline06"
        C_帐密[1] = "yabe@2016"
        C_帐密["id"] = 1
        窗口设置大小(窗口获取自我句柄(),487,617)
    end
    if(!C_调试)
        C_Web = "http://yabeline.tw/Member2.php"
        C_网域 = "http://yabeline.tw/"
    else
        C_Web = "http://deve.yabeline.tw/Member2.php"
        C_网域 = "http://deve.yabeline.tw/"
    end
    threadbegin("自动登入",局_开始)
    init_Main()
    var 局_控件 = array("按钮0","按钮2","Test")
    var 局_Value
    for(var i = 0; i < arraysize(局_控件); i++)
        arraygetat(局_控件,i,局_Value,null)
        controlshow(局_控件[i],false)
    end
    bmpToGif()
结束


function Sys_错误停止(参_错误)
    filewriteini("Action",C_帐密[0],"停止:" & 参_错误,C_配置路径)
end

function Sys_置讯息(参_讯息,参_状态=false)
    filewriteini("Action",C_帐密[0], 参_讯息,C_配置路径)
    if(参_状态)
        staticsettext("状态",参_讯息)
    end
end

function 自动登入(参_开始=false)
    
    while(true)
        
        webgo("浏览器0",C_Web)
        while(!网页加载("浏览器0"))
            sleep(100)
        end
        sleep(3000)
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


function Web_点选Boss(content,参_讯息="",参_不确定=false)//訊息為空 是中國訂單
    var 局_回报成功 = false,局_清空次数 = 0
    wlog("Web_點選Boss","準備處理Boss")
    if(网页元素选择("浏览器0",content,"tag:SELECT&name:Status&index:0"))
        sleep(200)
        网页元素点击("浏览器0","tag:INPUT&value:Boss")
        if(参_不确定) // 單純選擇不管用那個
            sleep(5000)
            return 
        end
        //        if(参_讯息 != "")
        //            for(var i = 0; i < 5; i++)
        //                sleep(3000)
        //                局_回报成功 = Web_is回报完成(参_讯息) //詢問服務器是否回報成功
        //                if(局_回报成功)
        //                    break
        //                end
        //            end
        //        else
        //            局_回报成功 = true
        //        end
        //        
        //        if(!局_回报成功 && 参_讯息 != "") //非中國訂單且回報失敗
        //            异常推播("回報失敗 準備點選Boss的訊息為" & 数组转资讯(参_讯息))
        //            Sys_错误停止("回報失敗")
        //            wlog("Web_點選Boss","回報失敗 準備點選Boss的訊息為" & 数组转资讯(参_讯息))
        //            // messagebox("回報失敗 準備點選Boss的訊息為" & 数组转资讯(参_讯息),C_帐密[0])
        //            启动停止_点击()
        //            return false
        //        elseif(局_回报成功)
        //            wlog("Web_點選Boss","確認訂單回報成功,資料一致")
        //        end
        if((strfind(参_讯息,"異常A")> -1 || strfind(参_讯息,"異常B")> -1 || strfind(参_讯息,"異常C")> -1 || strfind(参_讯息,"異常Z")> -1) && !C_调试)
            异常推播(数组转资讯推播整理(参_讯息,"",true))
        end
        //todo 要等頁面跳轉完
        Sqlite_写订单("")
        staticsettext("状态","")
        while(Sqlite_读订单() != "") //如果寫入為空，但是讀出又不為為空
            局_清空次数 = 局_清空次数 + 1
            wlog("Web_點選Boss","Sqlite清空失敗，準備重試")
            sleep(200)
            filedelete(C_DB_OrderPath)
            sleep(200)
            if(局_清空次数>=5)
                sleep(2000)
                逍遥_关闭模拟器(false)
                sleep(2000)
                退出()
            end
            init_SqlPath()
        end
        if(isarray(参_讯息))
            Sql写回报(参_讯息["id"],content,参_讯息["Remark"])
        end
        return true
    else
        wlog("Web_點選Boss","選擇回報狀態失敗",false)
    end
    sleep(5000)
    return false
end

function Web_资料符合(参_国家网址) //订单资料 和 页面资料是否符合
    wlog("Web_資料符合","準備比對資料是否符合",false)
    sleep(500)
    var 局_网址 = strreplace(网页获取超链接("浏览器0"),"#","")
    if(参_国家网址 != 局_网址)
        messagebox("應轉向網址:" & 参_国家网址 & "\r\n 當前網址:" & 局_网址,"異常網址")
    end
    var 局_贴图网址 = Web_取订单资料_取LineWeb(http_获取源码(局_网址))  //http获取页面源码(局_网址,"utf-8")
    var 局_数组资料=array(),局_贴图网址2,局_资料 = Sqlite_读订单()
    局_数组资料 = 局_资料
    var 局_ID = 网页元素获取("浏览器0","value","tag:INPUT&type:text&index:2&class:form-control")
    // var 局_贴图网址 = 网页元素获取("浏览器0","value","tag:INPUT&index:8") 
    var 局_异常状况 = 网页元素获取("浏览器0","text","tag:FONT&index:2")
    局_异常状况 = strreplace(局_异常状况,"【","")
    局_异常状况 = strreplace(局_异常状况,"】","")
    
    if(!Web_比对页面id和网址(局_数组资料["ID"],局_数组资料["LineWeb"]))
        messagebox("發圖結果與訂單結果不符合，網頁ID:" & 局_ID & "   訂單ID:" & 局_数组资料["ID"] & "  網頁網址:" & 局_贴图网址 & "   訂單網址:" & 局_数组资料["LineWeb"],C_帐密["0"])
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
    
结束

var C_更新检测时间
function 逍遥_更新Apk()
    if(!C_更新检测时间  || 时间间隔("s",当前时间(),C_更新检测时间) < -10)
        C_更新检测时间 = 当前时间()
        var 局_最新版本号 = 系统获取系统路径(4) & "\\Downloads\\逍遙安卓下載\\Update\\Version.txt"
        var 局_当前版本号 = C_个别资料夹 & "Version.txt"
        if(!fileexist(局_当前版本号))
            return false //等他寫完資料
        end
        if(staticgettext("状态") == "目前無訂單，抓取新訂單中")
            if(filereadex(局_最新版本号)> filereadex(局_当前版本号))
                xy_卸载apk("MEmu_" & C_帐密["id"],"com.yabe")
                xy_安装apk("MEmu_" & C_帐密["id"],"C:\\Users\\Lu\\Downloads\\逍遙安卓下載\\Update\\YabeRobot.apk")
                sleep(2000)
                xy_运行app("MEmu_" & C_帐密["id"],"com.yabe","com.yabe.UserActivity")
                sleep(2000)
            end
        end
    end
    
    
    
end


功能 按钮1_点击()
    
    
    return
    var s = "var a = document.getElementsByName(\"Line_ID\");return a[1].value;"
    traceprint(网页执行js("浏览器0",s))
    
    
    return
    获取页面资讯()
结束


功能 按钮2_点击()
    //var 局_ = Web_取订单资料_单纯取资料("日本")
    //Sqlite_写订单(局_)
    
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
    // var 局_讯息 = 窗口获取标题(窗口获取自我句柄()) & "    " & 参_讯息
    var 局_讯息 = 参_讯息 & "Processr：" & 窗口获取标题(窗口获取自我句柄())
    变量 header = 数组()
    header["Accept"] = "*/*"
    header["User-Agent"] = "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:17.0) Gecko/17.0 Firefox/17.0"
    header["Accept-Language"] = "zh-CN,en-US;q=0.5"
    header["Accept-Encoding"] = "deflate"
    header["Cache-Control"] = "no-cache"
    //变量 body = http提交请求("get","http://ok963963ok.synology.me/Yabe/getError.php?Error="& 局_讯息,"","utf-8",header,"",true,3000)
    变量 body = http提交请求("get","http://ok963963ok.synology.me/Yabe/PushError.php?Error="& 局_讯息,"","utf-8",header,"",true,3000)
    // 变量 body = http获取页面源码("http://ok963963ok.synology.me/Yabe/PushError.php?Error="& 局_讯息,"utf-8")
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
    var ret = http提交请求("GET",url&"?"&params,"","utf-8",null,"",true,3000)
    traceprint(ret)
    return ret
end

功能 BBY_TEST_点击()
    
    // threadbegin("yes_is已处理","")
    //主线程 = threadbegin("主线程","")
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
    Sqlite_写订单(局_资料)
    //messagebox(BBY_回报贴图资讯(C_帐密[0],editgettext("ID"),editgettext("Web"),editgettext("Country"),editgettext("Error"),true)) //仿造訂單
结束




功能 启动停止_点击()
    
    if(buttongettext("启动停止") == "啟動")
        buttonsettext("启动停止","停止")
        wlog("啟動停止_點擊","啟動")
        文件覆盖内容(C_运作路径,"Run")
        主线程 = threadbegin("主线程","")
        监测线程 = threadbegin("AppCarshCheckThread","")
        
    else
        文件覆盖内容(C_运作路径,"Stop") //让模拟器App可以停止
        Sys_置讯息("停止",true)
        wlog("啟動停止_點擊","停止")
        filedelete(C_个别资料夹 & "發圖中.txt")
        buttonsettext("启动停止","啟動")
        threadclose(主线程)
        threadclose(监测线程)
    end
    
结束


//点击关闭_执行操作
功能 Yabe_Client_关闭()
    threadclose(主线程)
    threadclose(监测线程)
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



function http_获取源码(参_网址,参_源码="")
    Global_源码开关 = true
    var 局_返回,局_响应,header = array("Accept" = "*/*")
    if(参_源码 == "")
        局_返回 =  http获取页面源码(参_网址,"utf-8")
    else
        局_返回 = http提交请求扩展("get",参_网址,参_源码,"",局_响应,header,"utf-8")
    end
    
    Global_源码开关 = false
    return 局_返回
end


//消息路由功能
功能 Yabe_Client_消息路由(句柄,消息,w参数,l参数,时间,x坐标,y坐标)
    
    返回 假
结束


//消息过程功能
功能 Yabe_Client_消息过程(消息,w参数,l参数)
    if(w参数 == 120 && l参数 == 120)
        if(buttongettext("启动停止") == "停止")
            启动停止_点击()
        end
    end
    if(w参数 == 5000 && l参数 == 5000)
        if(staticgettext("状态") == "目前無訂單，抓取新訂單中")
            C_订单标志 = true
        end
    end
结束



功能 getID_点击()
    var a = array(),id
    for(var i = 2; i < strsplit(filereadex("a:\\id.txt"),"\r\n",a); i++)
        if(a == "")
            break
        end
        id = id & a[i] & ","
        
    end
    traceprint(arraysize(a))
    设置剪切板(id)
结束
