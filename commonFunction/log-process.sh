###################################################################################################
# log-process.sh:
#    public
#
#Purpose:
#        日志审计函数封装
#
#Author:
#    1014263039@qq.com  ---Liu
#
#Creating Time:
#    2021-03-19
###################################################################################################

# 日志审计需要定义
#  1 日志级别
#  2 输出日志目录


# 全局变量定义
# 1 日志级别
GLOBAL_LOG_INFO=INFO
GLOBAL_LOG_WARN=WARN
GLOBAL_LOG_ERROR=ERROR

# 不同类型的变量之间定义，空一行
# 2 指定日志的输出目录，复杂场景需要添加 时间后缀
GLOBAL_LOG_OUTFILE="`pwd`/output.log"

# 模块名称
GLOBAL_MODULE_NAME="LogProess"

# 函数功能
#   记录和显示 error级日志
# 参数说明
#   $1 : 要输出的错误信息
function echoError()
{
    # 局部变量的使用，可以在特殊场景下可以屏蔽全局变量在使用中，被串改值的问题
    local local_current_time=$(date +%Y-%m-%d-%H:%M:%S)
    echo "${local_current_time} ${GLOBAL_LOG_ERROR}: [${GLOBAL_MODULE_NAME}] $1" >> ${GLOBAL_LOG_OUTFILE}
    printf "\\033[1;31m    ***Error: $1 !***\\033[0m\n" # 红色显示
}

# 函数功能
#   记录和显示 warning级日志
# 参数说明
#   $1 : 要输出的告警信息
function echoWarning()
{
    local local_current_time=$(date +%Y-%m-%d-%H:%M:%S)
    echo "${local_current_time} ${GLOBAL_LOG_WARN}: [${GLOBAL_MODULE_NAME}] $1" >> ${GLOBAL_LOG_OUTFILE}
    printf "\\033[1;35m $1 \\033[0m\n" # 红色显示
}

# 函数功能
#   记录和显示 info级日志
# 参数说明
#   $1 : 要输出的有用信息
function echoInfo()
{
    local local_current_time=$(date +%Y-%m-%d-%H:%M:%S)
    echo "${local_current_time} ${GLOBAL_LOG_INFO}: [${GLOBAL_MODULE_NAME}] $1" >> ${GLOBAL_LOG_OUTFILE}
    printf "\\033[1;32m $1 \\033[0m\n" # 绿色显示
}

# 只记录日志，不显示的信息
function recordError()
{
    local local_current_time=$(date +%Y-%m-%d-%H:%M:%S)
    echo "${local_current_time} ${GLOBAL_LOG_ERROR}: [${GLOBAL_MODULE_NAME}] $1" >> ${GLOBAL_LOG_OUTFILE}
}

function recordWarning()
{
    local local_current_time=$(date +%Y-%m-%d-%H:%M:%S)
    echo "${local_current_time} ${GLOBAL_LOG_WARN}: [${GLOBAL_MODULE_NAME}] $1" >> ${GLOBAL_LOG_OUTFILE}
}

function recordInfo()
{
    local local_current_time=$(date +%Y-%m-%d-%H:%M:%S)
    echo "${local_current_time} ${GLOBAL_LOG_INFO}: [${GLOBAL_MODULE_NAME}] $1" >> ${GLOBAL_LOG_OUTFILE}
}