

function init_Main()
    init_逍遥资料夹()
    //init_开启模拟器() 已经交给Center 去处理
    init_国家名称()
    init_国家网址()
    windowsetcaption(windowgetmyhwnd(),C_帐密[0])
    init_运作路径()
    init_SqlPath()
    init_个别资料夹()
    init_Running()
    init_归零订单数量()
    init_LogFold()
    init_删除文件锁()
    C_回报失败次数 = 0
end

function init_删除文件锁()
    filedelete(C_个别资料夹 & "eread.txt")
    filedelete(C_个别资料夹 & "cread.txt")
    filedelete(C_个别资料夹 & "發圖中.txt")
end

function init_LogFold()
    var 局_路径 = 系统获取进程路径() & "Log\\"
    if(!fileexist(局_路径))
        文件夹创建(局_路径)
    end
    if(!fileexist(局_路径 & C_帐密[0]))
        foldercreate(局_路径 & C_帐密[0])
    end
end

function init_归零订单数量()
    filewriteini("訂單數",C_帐密[0],"0",C_配置路径)
end

function init_Running()
    文件覆盖内容(C_个别资料夹 & "Running.txt",指定时间("s",-30,当前时间()))
end

function init_SqlPath() // 初始化Sqlite 路徑
    var 局_路径 = C_Noxshare & C_帐密[0] & "\\",局_数组
    if(!fileexist(局_路径))
        foldercreate(局_路径)
    end
    C_DB_Path = 局_路径& C_帐密[0] & ".db"
    sqlitesqlarray(C_DB_Path,"SELECT name FROM sqlite_master WHERE type='table'",局_数组)
    if(!局_数组)
        sqlitesqlarray(C_DB_Path,"create table if not exists `log` (ID1 INTEGER PRIMARY KEY AUTOINCREMENT,id varchar(50),訂單資料 varchar(50),接收時間 datetime,處理結果 varchar(50),APP處理結果 varchar(50),處理時間 datetime,備註 varchar(10))",局_数组)
    end
    C_DB_OrderPath = C_Noxshare & C_帐密[0] & "\\" & C_帐密[0] & "Order.db"
    sqlitesqlarray(C_DB_OrderPath,"SELECT name FROM sqlite_master WHERE type='table'",局_数组)
    if(!局_数组)
        sqlitesqlarray(C_DB_OrderPath,"create table if not exists `OrderData` (Data varchar(50))",局_数组)
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

function init_逍遥资料夹()
    C_Noxshare = 系统获取系统路径(4) & "Downloads\\逍遙安卓下載\\"
    Cy_夜神路径 = filereadini("Path","夜神路徑",C_配置路径)
    //Cy_OrderPath = C_Noxshare & "Cy_OrderPath.ini"
    Cy_OrderPath = C_Noxshare & C_帐密[0] & "Order.txt"
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
    var 局_Key
    arraypush(Cw_国家网址,C_YabeWeb & "Friend_Stickers_Send.php","臺灣")
    arraypush(Cw_国家网址,C_YabeWeb & "Friend_Stickers_Send.php?Country=ja","日本")
    arraypush(Cw_国家网址,C_YabeWeb & "Friend_Stickers_Send.php?Country=us","美國")
    arraypush(Cw_国家网址,C_YabeWeb & "Friend_Stickers_Send.php?Country=de","德國")
    arraypush(Cw_国家网址,C_YabeWeb & "Friend_Stickers_Send.php?Country=IT","義大利")
    arraypush(Cw_国家网址,C_YabeWeb & "Friend_Stickers_Send.php?Country=fr","法國")
    arraypush(Cw_国家网址,C_YabeWeb & "Friend_Stickers_Send.php?Country=th","泰國")
    arraypush(Cw_国家网址,C_YabeWeb & "Friend_Stickers_Send.php?Country=id","印尼")
    arraypush(Cw_国家网址,C_YabeWeb & "Friend_Stickers_Send.php?Country=in","印度")
    arraypush(Cw_国家网址,C_YabeWeb & "Friend_Stickers_Send.php?Country=es","西班牙")
    arraypush(Cw_国家网址,C_YabeWeb & "Friend_Stickers_Send.php?Country=hk","香港")
    arraypush(Cw_国家网址,C_YabeWeb & "Friend_Stickers_Send.php?Country=ar","阿根廷")
    arraypush(Cw_国家网址,C_YabeWeb & "Friend_Stickers_Send.php?Country=mx","墨西哥")
    arraypush(Cw_国家网址,C_YabeWeb & "Friend_Stickers_Send.php?Country=my","馬來西亞")
    arraypush(Cw_国家网址,C_YabeWeb & "Friend_Stickers_Send.php?Country=bs","巴西")
    arraypush(Cw_国家网址,C_YabeWeb & "Friend_Stickers_Send.php?Country=cn","中國")
    arraypush(Cw_国家网址,C_YabeWeb & "Friend_Stickers_Send.php?Country=kr","韓國")
    arraypush(Cw_国家网址,C_YabeWeb & "Friend_Stickers_Send.php?Country=ru","俄羅斯")
    for(var i = 0; i < arraysize(Cw_国家网址); i++)
        arraygetat(Cw_国家网址,i,null,局_Key)
        comboaddtext("优先国家",局_Key)
    end
end

