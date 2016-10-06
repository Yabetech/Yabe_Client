function wlog(参_函数,参_讯息,参_显示=true)
    var 局_讯息 = "【"  & 参_函数 & "】\t" & 当前时间() & "\t\t" & 参_讯息
    文件写日志(局_讯息,log_档案是否存在())
    if(参_显示)
        var now = 当前时间()
        var 局_秒 = 时间秒(now)
        if(cint(局_秒)<10)
            局_秒 = "0" & 局_秒
        end
        editsettext("Log",editgettext("Log") & strformat("%s:%s:%s",时间时(now),时间分(now),局_秒) & "  "&参_讯息 & "\r\n")
        窗口发送消息(controlgethandle("Log"),#115,#7,0)
    end
end

function log_档案是否存在()
    var now = 当前时间()
    var 局_路径 = 系统获取进程路径() & "Log\\" & C_帐密[0] & "\\" & strformat("%s_%s_%s.txt",时间年(now),时间月(now),时间日(now))
    if(!fileexist(局_路径))
        文件关闭(文件创建(局_路径))
    end
    return 局_路径
end

