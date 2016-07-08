function Auto_SetLineId(参_ID)
    网页执行js("浏览器0","var s = document.getElementsByClassName(\"idInput\");for(var i=0;s.length;i++){ s[i].value = '"& 参_ID & "'; }")
end

function AutoReadList(参_路径)
    var 局_内容 = filereadex(参_路径),局_清单数组 = array()
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
        if(等待元素出现("tag:BUTTON&txt:加入購物車","text","加入購物車",10))
            网页元素点击("浏览器0","tag:BUTTON&txt:加入購物車")
            sleep(2000)
        end
        
    end
    网页跳转("浏览器0","http://deve.yabeline.tw/Shopping_Cart.php")
    等待元素出现("class:form-control btn btn-success&txt:前往結帳","text","前往結帳")
    Auto_SetLineId(editgettext("ID"))
    网页元素点击("浏览器0","class:form-control btn btn-success&txt:前往結帳")
    等待元素出现("txt:資料正確，確定結帳","text","資料正確，確定結帳")
    网页元素点击("浏览器0","class:btn btn-success btn-lg btn-block")
    
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