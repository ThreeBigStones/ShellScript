###################################################################################################
# param-analyse-pattern.sh:
#    public
#
#Purpose:
#        参数解析函数应用：
#              实例应用场景：升级安装包，升级，恢复场景支持
#
#Author:
#    1014263039@qq.com  ---Liu
#
#Creating Time:
#    2021-03-18
###################################################################################################
#! /usr/bin/bash

export LC_ALL=C

# return code
SUCCEEDED=0

# global variable
GLOBAL_IS_NEED_HELP="no"
GLOBAL_UPDATE_MODE=""
GLOBAL_INSTALL_PATH=""

# import commfunc
# . parameter-analyse.sh
# 这里先注释掉 直接拿需要的函数来运行

function getKeyName ()
{
    echo $1 | awk -F"=" '{print $1}'
}

function getValueName ()
{
    echo $1 | awk -F"=" '{print $2}'
}

# 参数解析函数的功能是 将入参转化为脚本内部变量 
#
function paramAna()
{
    # 没有入参 执行help函数
    if [ $# == 0 ]; then
        GLOBAL_IS_NEED_HELP="yes"
    fi

    # 参数解析
    for params in $@
    do
        local LOCAL_KEY_NAME=`getKeyName $params`
        case "${LOCAL_KEY_NAME}" in
            "--app-path")
                GLOBAL_INSTALL_PATH=`getValueName $params`
                ;;
            "--update-mode")
                GLOBAL_UPDATE_MODE=`getValueName $params`
                ;;
            "--help")
                GLOBAL_IS_NEED_HELP=`getValueName $params`
                ;;
            *)
            GLOBAL_IS_NEED_HELP="yes"
            echo "Unknown parameter $params"
            break
            ;;
        esac
    done
}

# 检查函数功能：
#  1 入参是否合法
#  2 做执行动作分发
function checkParm()
{
    # 显示帮助信息
    if [ "xyes" == "x${GLOBAL_IS_NEED_HELP}" ]; then
        ShowHelp
        exit ${SUCCEEDED}
    fi
}

# 帮助函数说明
function ShowHelp()
{
    echo "update Product Package on the current system. "
    echo ""
    echo "Usage: $0 [VAR=VALUE]..."
    echo "parameter:"
    echo "  --app-path=/home/test                  install path(eg. /home/test)"
    echo "                                         "
    echo "  --update-mode=update                   upodate mode [update|delete]"
    echo "                                        "
    echo "  --help=yes                              help [yes|no] info"
    echo "                                        "
    echo "eg1: $0 --app-path=/home/test --update-mode=update"
    echo "eg2: $0 --help"
    echo ""
}


function main()
{
    paramAna $@
    checkParm
}

main $@