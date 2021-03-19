## Shell Common  Function
### 目的

记录常用的shell脚本函数封装。
记录shell模式化的写法 (参数解析，配置文件读取，自定义语法规则等)
记录特殊场景下的异常处理 (字符或者sed模式空间的匹配问题，跨平台语法区别问题ksh bash等)

### 目录结构
##### |----commonFunction
##### |----exceptionCase
##### |----patternMethods

### 测试使用环境
bash shell

#### 规范脚本写法统一 

规范写法是为了在工程应用场景下，功能结构不至于混乱。**举例：**
```
#! /usr/bin/bash

# 脚本输出选择英文输出
export LC_ALL=C   

# 定义脚本返回值
# return code
SUCCEEDED=0
FAILED_NO_SPACE=1
FAILED_RESTART=2

# 定义全局变量
# 全局变量以 GLOBAL开头， 局部变量以local开头
GLOBAL_CURRENT_WORKBENCH=`pwd`
GLOBAL_PRODUCT_TYPE="SSSSS"
GLOBAL_SERVICE_NAME=```

#定义日志级别 和输出路径
# 1 日志级别
GLOBAL_LOG_INFO=INFO
GLOBAL_LOG_WARN=WARN
GLOBAL_LOG_ERROR=ERROR

# 不同类型的变量之间定义，空一行
# 2 指定日志的输出目录，复杂场景需要添加 时间后缀
GLOBAL_LOG_OUTFILE="`pwd`/output.log"


# 导出 公共函数
. common-function.sh

# 定义脚本中独有函数(约定 所有的函数采用驼峰命名法，约定所有的脚本名称log-process.sh 的命名方法)

# show error information : 红色信息
function echoError()
{
    # 局部变量的使用，可以在特殊场景下可以屏蔽全局变量在使用中，被串改值的问题
    local local_current_time=$(date +%Y-%m-%d-%H:%M:%S)
    echo "${local_current_time} ${GLOBAL_LOG_ERROR}: [${GLOBAL_MODULE_NAME}] $1" >> ${GLOBAL_LOG_OUTFILE}
    printf "\\033[1;31m    ***Error: $1 !***\\033[0m\n" # 红色显示
}

# show info information : 绿色信息
function echoInfo()
{
    local local_current_time=$(date +%Y-%m-%d-%H:%M:%S)
    echo "${local_current_time} ${GLOBAL_LOG_INFO}: [${GLOBAL_MODULE_NAME}] $1" >> ${GLOBAL_LOG_OUTFILE}
    printf "\\033[1;32m $1 \\033[0m\n" # 绿色显示
}


# common function
##check left space 
function checkSpace()
{
    local local_left=`df -h ./ | awk '{print $4}' | sed -n '2p' | awk -FG '{print $1}'`
    if [ ${local_left} -lt 5 ]; then
       echoError "no left space!!"
       exit ${FAILED_NO_SPACE}
    fi
}

# 控制脚本执行流程函数 main
function main()
{
    ParamAna $@  # 参数解析
    checkParm    # 动作分发
}

# 一切开始的地方
main $@
````