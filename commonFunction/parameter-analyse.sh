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


. log-process.sh
# 函数功能：
#   配置文件中 参数替换
# 参数说明
#   $1 原来数据；$2 替换数据；$3 替换文件
function cfgSedReplace()
{
    if [ $# != 3 ];then
        echoError "func cfgSedReplace must be Three parameters"
        recordError "you parameters are $@"
        exit 1
    fi

    sed -i "s%${1}%${2}%g" ${3}
    recordInfo "Configure ${3} ,Replace data ${1} with ${2}"
}

# 函数功能：
#   ini 配置文件解析
# 参数说明
#   $1 解析文件名称(svr.ini); $2 section名; $3 item 名称
# svr.ini 格式
# [admin]
#   user=root
# [Product]
#    servertype=MASTER
#    language=Chinese
# [Network]
#    dbbip=192.168.255.252
function readIni() 
{
    local local_file=$1;
    local local_section=$2;
    local local_item=$3;
    local local_value=$(awk -F '=' '/\['${local_section}'\]/{a=1} (a==1 && "'${local_item}'"==$1){a=0;print $2}' ${local_file})
    echo ${local_value}
}