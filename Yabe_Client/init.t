

function init_Main()
    init_夜神资料夹()
    init_开启模拟器()
    init_国家名称()
    init_国家网址()
    windowsetcaption(windowgetmyhwnd(),C_帐密[0])
    init_运作路径()
    initSqlPath()
    init_个别资料夹()
    init_Running()
end

function init_Running()
    文件覆盖内容(C_个别资料夹 & "Running.txt",指定时间("s",-30,当前时间()))
end

function initSqlPath() // 初始化Sqlite 路徑
    var 局_路径 = C_Noxshare & C_帐密[0] & "\\",局_数组
    if(!fileexist(局_路径))
        foldercreate(局_路径)
        
    end
    C_DB_Path = 局_路径& C_帐密[0] & ".db"
    sqlitesqlarray(C_DB_Path,"SELECT name FROM sqlite_master WHERE type='table'",局_数组)
    if(!局_数组)
        sqlitesqlarray(C_DB_Path,"create table if not exists `log` (id varchar(50),訂單資料 varchar(50),接收時間 datetime,處理結果 varchar(50),處理時間 datetime,備註 varchar(10))",局_数组)
    end
    
    
end

function init_个别资料夹()
    C_个别资料夹 = C_Noxshare & C_帐密[0] & "\\"
    //traceprint("C_个别资料夹" & C_个别资料夹)
    文件覆盖内容(C_个别资料夹 & "isRestart.txt","")
end

function init_运作路径()
    C_运作路径 = C_Noxshare & C_帐密[0] & "Run.txt"
    if(!fileexist(C_运作路径))
        文件覆盖内容(C_运作路径,"",2)
    end
end

function init_夜神资料夹()
    C_Noxshare = 系统获取系统路径(4) & "Nox_share\\Other\\"
    Cy_夜神路径 = filereadini("Path","夜神路徑",C_配置路径)
    //Cy_OrderPath = C_Noxshare & "Cy_OrderPath.ini"
    Cy_OrderPath = C_Noxshare & C_帐密[0] & "Order.txt"
end



function init_开启模拟器()
    if(!C_调试)
        cmd(strformat("%s -clone %s",Cy_夜神路径,C_帐密[0]),true)
    end
end

function init_国家名称()
    arraypush(C_国家英文,"Taiwan","臺灣")
    arraypush(C_国家英文,"Japan","日本")
    arraypush(C_国家英文,"Thailand","泰國")
    arraypush(C_国家英文,"United States","美國")
    arraypush(C_国家英文,"Hong Kong","香港")
    arraypush(C_国家英文,"Indonesia","印尼")
    arraypush(C_国家英文,"Korea","韓國")
    arraypush(C_国家英文,"Spain","西班牙")
    arraypush(C_国家英文,"Brazil","巴西")
    arraypush(C_国家英文,"Malaysia","馬來西亞")
    arraypush(C_国家英文,"China","中國")
end

function init_国家网址()
    arraypush(Cw_国家网址,"http://deve.yabeline.tw/Friend_Stickers_Send.php","臺灣")
    arraypush(Cw_国家网址,"http://deve.yabeline.tw/Friend_Stickers_Send.php?Country=ja","日本")
    arraypush(Cw_国家网址,"http://deve.yabeline.tw/Friend_Stickers_Send.php?Country=us","美國")
    arraypush(Cw_国家网址,"http://deve.yabeline.tw/Friend_Stickers_Send.php?Country=th","泰國") //todo 補全英文
    arraypush(Cw_国家网址,"http://deve.yabeline.tw/Friend_Stickers_Send.php?Country=id","印尼") //todo 補全英文
    arraypush(Cw_国家网址,"http://deve.yabeline.tw/Friend_Stickers_Send.php?Country=in","印度") //todo 補全英文
    arraypush(Cw_国家网址,"http://deve.yabeline.tw/Friend_Stickers_Send.php?Country=es","西班牙") //todo 補全英文
    arraypush(Cw_国家网址,"http://deve.yabeline.tw/Friend_Stickers_Send.php?Country=hk","香港") //todo 補全英文
    arraypush(Cw_国家网址,"http://deve.yabeline.tw/Friend_Stickers_Send.php?Country=ar","阿根廷") //todo 補全英文
    arraypush(Cw_国家网址,"http://deve.yabeline.tw/Friend_Stickers_Send.php?Country=mx","墨西哥") //todo 補全英文
    arraypush(Cw_国家网址,"http://deve.yabeline.tw/Friend_Stickers_Send.php?Country=my","馬來西亞") //todo 補全英文
    arraypush(Cw_国家网址,"http://deve.yabeline.tw/Friend_Stickers_Send.php?Country=bs","巴西") //todo 補全英文
    arraypush(Cw_国家网址,"http://deve.yabeline.tw/Friend_Stickers_Send.php?Country=cn","中國") //todo 補全英文
    arraypush(Cw_国家网址,"http://deve.yabeline.tw/Friend_Stickers_Send.php?Country=kr","韓國") //todo 補全英文
    
end

