
function yes_is已处理()
    var a = com("MSL.File"),局_跳转失败 = true
    var 局_内容 = a.ReadAllTextUTF8(Cy_OrderPath)
    if(strfind(局_内容,"已處理")>-1)
        var 局_Data = stringtoarray(局_内容)
        webgo("浏览器0",Cw_国家网址[局_Data["Country"]])
        for(var i = 0; i < 15; i++)
            
            staticsettext("状态","跳轉網頁" & cstring(i))
            traceprint(网页元素获取("浏览器0","value","name:Line_ID"))
            if(网页元素获取("浏览器0","value","name:Line_ID")!="")
                局_跳转失败 = false
                break
            end
            sleep(1000)
        end
        if(局_跳转失败)//todo 設定回報
            messagebox("跳轉網頁失敗")
            return false
        end
        if(!Web_资料符合())
            return false
        end
        staticsettext("订单资料","")
        Web_点选Boss(局_Data["Message"],局_Data) //写回报后会把Order.txt净空
        if(Web_取订单资料(局_Data["Country"]))//再次取同一個國家看看
            traceprint("有相同國家訂單")
        end
        Web_取待送国家()
        return true
    end
    return false
end

function yes_写订单(参_资料)
    文件写配置("Order",C_帐密[0] & "_ID",参_资料,Cy_OrderPath)
end

function yes_关闭模拟器()
    var 局_Nox路径 = filereadini("Path","夜神路徑",C_配置路径)
    var 局_命令 = strformat("%s -clone:Nox_%s -quit" ,局_Nox路径,C_帐密["id"])
    traceprint(局_命令)
    cmd(局_命令,false)
    退出()
end