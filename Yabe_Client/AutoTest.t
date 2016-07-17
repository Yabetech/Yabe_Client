function Auto_SetLineId(参_ID)
    网页执行js("浏览器0","var s = document.getElementsByClassName(\"idInput\");for(var i=0;s.length;i++){ s[i].value = '"& 参_ID & "'; }")
end

function AutoReadList(参_路径)
    var 局_ID清单 = array()
    if(strfind(editgettext("ID"),",")>0)
        strsplit(editgettext("ID"),",",局_ID清单)
    else
        局_ID清单[0] = editgettext("ID")
    end
    for(var i = 0; i < arraysize(局_ID清单); i++)
        自动下单单元(参_路径,局_ID清单[i])
    end
    
end

function 自动下单单元(参_路径,参_ID)
    var 局_内容 = filereadex(参_路径),局_清单数组 = array(),局_名称
    var 局_行数 = 文件获取行数(参_路径)
    for(var i = 0; i < 局_行数; i++)
        var 局_当前行内容 = 文件读指定行(参_路径,i)
        if(局_当前行内容 == "")
            return false
        end
        traceprint(局_当前行内容)
        
        if(strfind(局_当前行内容,"http")>-1)
            网页跳转("浏览器0",局_当前行内容)
        else
            网页跳转("浏览器0", "http://deve.yabeline.tw/Stickers_Data.php?Number=" & 局_当前行内容)
        end
        while(局_名称 == 网页元素获取("浏览器0","text","tag:DIV&index:14"))
            traceprint("等待跳轉完成")
            sleep(100)
        end
        if(等待元素出现("tag:BUTTON&txt:加入購物車","text","加入購物車",10))
            局_名称 = 网页元素获取("浏览器0","text","tag:DIV&index:14")
            网页元素点击("浏览器0","tag:BUTTON&txt:加入購物車")
            sleep(500)
        end
        
    end
    网页跳转("浏览器0","http://deve.yabeline.tw/Shopping_Cart.php")
    等待元素出现("class:form-control btn btn-success&txt:前往結帳","text","前往結帳")
    Auto_SetLineId(参_ID)
    网页元素点击("浏览器0","class:form-control btn btn-success&txt:前往結帳")
    等待元素出现("txt:資料正確，確定結帳","text","資料正確，確定結帳")
    网页元素点击("浏览器0","class:btn btn-success btn-lg btn-block")
    等待元素出现("tag:BUTTON&type:button","text","發圖進度")
    
end

function 等待元素出现(参_元素特征,参_元素类别,参_结果,参_秒数 = 15)
    
    for(var i = 0; i < 参_秒数; i++)
        sleep(1000)
        if(网页元素获取("浏览器0",参_元素类别,参_元素特征) == 参_结果)
            return true
        end
        
    end
    return false
end