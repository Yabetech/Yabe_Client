var __xyPath

function xy路径()
    return 获取资源路径("rc:xyaz.dll")
end

function xy_取所有模拟器adb信息()
    
    return dllcall(xy路径(), "char *", "GetAllVmsAdbInfo")
end

function xy_取标题句柄(参_名称)
    return dllcall(xy路径(), "char *", "GetHwndAndTitleByVmName", "char *", 参_名称)
end

function xy_运行模拟器(参_名称, 参_关闭 = true)
    if(参_关闭)
        xy_关闭模拟器(参_名称)
    end
    sleep(200)
    //cmd(xy_获取安装路径() &"\\MEmu\\MEmu " & 参_名称,true)
    traceprint(xy_获取多开器路径() & " " & 参_名称)
    进程打开ex(xy_获取多开器路径(),参_名称)
    //cmd(xy_获取多开器路径() & " " & 参_名称, true)
end

function xy_置imei(参_名称)
    var 局_imei = ""
    for(var i = 0; i < 15; i ++)
        sleep(随机数(1, 9))
        局_imei = 局_imei & cstring(随机数(1, 9)) 
    end
    cmd(xy_取Manage路徑路径() & " guestproperty set \"" & 参_名称 & "\" imei " & 局_imei, true)
end



function xy_关闭模拟器(参_名称, 参_新版 = true)
    var 局_字串去除2 = "安卓 " & xy_取版本() & " - ", 局_窗口数组
    var 局_窗口集 = strsplit(枚举窗口(局_字串去除2, 0), "|", 局_窗口数组)
    var hd 
    for(var i = 0; i < arraysize(局_窗口数组); i ++)
        var 局_标题 = 窗口获取标题(局_窗口数组[i])
        if(strfind(局_标题, 参_名称) > -1)
            hd = 局_窗口数组[i]
            break
        end
    end
    
    
    if(hd > 0)
        
        窗口关闭(hd)
    end
    sleep(3000)
    //    cmd(xy_取Manage路徑路径() & " controlvm \""& 参_名称 &"\" poweroff",true)
    //    sleep(3000)
end





function xy_取运行状态(参_名称)
    // "Started."  运行中 "Starting." 启动中  "Not start or Starting." 未知状态
    return dllcall(xy路径(), "char *", "CheckVmsStatus", "char *", 参_名称)
end

function xy_关侧边栏(参_名称, &参_错误讯息 = null)
    var 局_返回 = dllcall(xy路径(), "char *", "CloseVmsSideBar", "char *", 参_名称)
    if(局_返回 == "Sidebar hide success." || 局_返回 == "Sidebar already hided.")
        return true
    else
        参_错误讯息 = 局_返回 // Can not find vms window. 或 Sidebar not exist.
        return false
    end
end

function xy_发字串(参_名称, 参_字串)
    return dllcall(xy路径(), "char *", "SendmessageToVms", "char *", 参_名称, "char *", 参_字串)
end

function xy_安装apk(参_名称, 参_路径, &参_错误讯息 = null)
    
    var 局_返回 = dllcall(xy路径(), "char *", "InstallApkToVms", "char *", 参_名称, "char *", 参_路径)
    if(局_返回 == "Apk installed success.")
        return true
    else
        参_错误讯息 = 局_返回
        return false
    end
end

function xy_卸载apk(参_名称,参_包名, &参_错误讯息 = null)
    var 局_返回 = dllcall(xy路径(), "char *", "UninstallVmsApk", "char *", 参_名称, "char *", 参_包名)
    if(strfind(局_返回,"Success")>-1)
        return true
    else
        参_错误讯息 = 局_返回
        return false
    end
end

function xy_运行app(参_名称, 参_包名, 参_类名, &参_错误讯息 = null)
    
    var 局_返回 = dllcall(xy路径(), "char *", "RunVmsApk", "char *", 参_名称, "char *", 参_包名, "char *", 参_类名)
    if(局_返回 == "Success.")
        return true
    else
        参_错误讯息 = 局_返回
        return false
    end
end

function xy_关闭app(参_包名, &参_错误讯息 = null)
    var 局_返回 = dllcall(xy路径(), "char *", "CloseVmsApk", "char *", 参_包名)
    if(局_返回 == "Apk close success.")
        return true
    else
        参_错误讯息 = 局_返回
        return false
    end
end

function xy_清理缓存(参_包名, &参_错误讯息 = null)
    var 局_返回 = dllcall(xy路径(), "char *", "ClearCacheVmsApk", "char *", 参_包名)
    if(局_返回 == "Apk cache clear success.")
        return true
    else
        参_错误讯息 = 局_返回
        return false
    end
end


function xy_创建模拟器()
    var 局_返回 = dllcall(xy路径(), "char *", "CreateVms")
    if(局_返回 == "Createing.")
        return true
    elseif(局_返回 == "System busy please wait.")
        return false
    end
end

function xy_克隆模拟器(参_名称, 参_超时 = 60)
    //功 能:按模拟器名称克隆模拟器
    for(var i = 0; i < 参_超时; i ++)
        var 局_返回 = dllcall(xy路径(), "char *", "CloneVms", "char *", 参_名称)
        if(局_返回 == "Cloneing.")
            return true
        elseif(局_返回 == "System busy please wait.")
            sleep(1000)
        end
    end
    traceprint("超时")
    return false
end

function xy_删除模拟器(参_名称)
    //    正常返回示例:
    //    Deleteing.
    //    否 则返回:
    //    System busy please wait.
    //    或
    //    Vms is still running. You can delete it after close it.
    //    遇到still running的提示，关闭模拟器后再执行
    return dllcall(xy路径(), "char *", "DeleteVms", "char *", 参_名称)
end


function xy_取版本()
    return 注册表获取键值("HKEY_LOCAL_MACHINE\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\MEmu", "DisplayVersion")
end

//=========================自己封装的=======================\\


function xy_获取安装路径()
    return 注册表获取键值("HKEY_LOCAL_MACHINE\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\MEmu", "InstallLocation")
end

function xy_获取多开器路径()
    return xy_获取安装路径() & "\\MEmu\\" & "MEmuConsole.exe"
end

function xy_取Manage路徑路径()
    return xy_获取安装路径() & "\\MEmuHyperv\\MEmuManage.exe"
end

function xy_取模拟器列表()
    var 局_文件夹
    文件遍历(xy_获取安装路径() & "\\MEmu\\MemuHyperv VMs", null, 局_文件夹)
    return 局_文件夹
end

function xy_置模拟器型号(参_模拟器, 参_型号)
    traceprint(xy_取Manage路徑路径() & " guestproperty set \"" & 参_模拟器 & "\" \"microvirt_vm_model\" \"" & 参_型号 & "\"")
    cmd(xy_取Manage路徑路径() & " guestproperty set \"" & 参_模拟器 & "\" \"microvirt_vm_model\" \"" & 参_型号 & "\"", true)
end

function xy_置下载路径(参_模拟器, 参_路径)
    // traceprint(xy_取Manage路徑路径() & " sharedfolder add \"" & 参_模拟器 & "\" --name \"download\" --hostpath \"" & 参_路径 & "\"")
    sleep(100)
    
    cmd(xy_取Manage路徑路径() & " sharedfolder remove \"" & 参_模拟器 & "\" --name \"download\"", true)
    sleep(500)
    cmd(xy_取Manage路徑路径() & " sharedfolder add \"" & 参_模拟器 & "\" --name \"download\" --hostpath \"" & 参_路径, true)
    sleep(500)
end

function xy_置内存(参_模拟器, 参_大小)
    cmd(xy_取Manage路徑路径() & " modifyvm \"" & 参_模拟器 & "\" --\"memory\" " & 参_大小, true)
    sleep(100)
end

function xy_置显存(参_模拟器, 参_大小)
    cmd(xy_取Manage路徑路径() & " modifyvm \"" & 参_模拟器 & "\" --\"vram\" " & 参_大小, true)
    sleep(100)
end

function xy_置Cpu(参_模拟器, 参_大小)
    cmd(xy_取Manage路徑路径() & " modifyvm \"" & 参_模拟器 & "\" --\"cpus\" " & 参_大小, true)
    sleep(20)
end

function xy_置解析度(参_模拟器, 参_宽, 参_高, 参_DPI = "192")
    sleep(20)
    cmd(xy_取Manage路徑路径() & " guestproperty set \"" & 参_模拟器 & "\" \"is_customed_resolution\" \"1\"", true)
    sleep(100)
    cmd(xy_取Manage路徑路径() & " guestproperty set \"" & 参_模拟器 & "\" \"resolution_height\" \"" & 参_高 & "\"", true)
    sleep(100)
    cmd(xy_取Manage路徑路径() & " guestproperty set \"" & 参_模拟器 & "\" \"resolution_width\" \"" & 参_宽 & "\"", true)
    
    sleep(100)
    cmd(xy_取Manage路徑路径() & " guestproperty set \"" & 参_模拟器 & "\" \"vbox_dpi\" \"" & 参_DPI & "\"", true)
    
end

//========================手机通用模组======================//
function Adb_检查档案(参_当前路径 = true, 参_路径 = "")
    var 局_档列表 = array("adb.exe", "AdbWinApi.dll", "AdbWinUsbApi.dll")
    for(var i = 0; i < arraysize(局_档列表); i ++)
        if(!fileexist(系统获取进程路径() & 局_档列表[i]))
            return false
        end
    end
    return true
end

function Adb_下载档案()
    var 局_档列表 = array("adb.exe", "AdbWinApi.dll", "AdbWinUsbApi.dll")
    http下载("http://ok963963ok.synology.me/temp/ADB/" & 局_档列表["0"], 系统获取进程路径() & 局_档列表["0"])
    http下载("http://ok963963ok.synology.me/temp/ADB/" & 局_档列表["1"], 系统获取进程路径() & 局_档列表["1"])
    http下载("http://ok963963ok.synology.me/temp/ADB/" & 局_档列表["2"], 系统获取进程路径() & 局_档列表["2"])
end

