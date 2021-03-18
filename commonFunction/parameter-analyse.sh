###################################################################################################
# parameter-analyse.sh:
#    public
#
#Purpose:
#        参数解析函数封装
#
#Author:
#    1014263039@qq.com  ---Liu
#
#Creating Time:
#    2021-03-18
###################################################################################################

# 定义一种格式
# --keyName=valueName
# 以 '=' 号为分隔符
function getKeyName ()
{
    echo $1 | awk -F"=" '{print $1}'
}

function getValueName ()
{
    echo $1 | awk -F"=" '{print $2}'
}

