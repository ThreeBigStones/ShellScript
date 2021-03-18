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
LOG_INFO=INFO
LOG_ERROR=ERROR
LOG_WARN=WARN
LOG_FILE="${GLOBAL_CURRENT_WORKBENCH}/logs/test.log"

# 导出 公共函数
. common-function.sh

# 定义脚本中独有函数

# show error information : 红色信息
ShowError ()
{
    Install_Time=$(date +%Y-%m-%d-%H:%M:%S)
    echo "${Install_Time} ${LOG_ERROR}: [${SERVER_NAME}] $1" >> ${LOG_FILE}
    printf "\\033[1;31m    ***Error: $1 !***\\033[0m\n"
}

# show info information : 绿色信息
ShowInfo ()
{
    Install_Time=$(date +%Y-%m-%d-%H:%M:%S)
    echo "${Install_Time} ${LOG_INFO}: [${SERVER_NAME}] $1" >> ${LOG_FILE}
    printf "\\033[1;32m $1 \\033[0m\n"
}


# common function
##check left space
function check_space()
{
    local LOCAL_LEFT=`df -h ./ | awk '{print $4}' | sed -n '2p' | awk -FG '{print $1}'`
    if [ ${LOCAL_LEFT} -lt 5 ]; then
       ShowError "no left space!!"
       exit ${FAILED_NO_SPACE}
    fi
}

# 控制脚本执行流程函数 main
function main()
{
    ParamAna $@
    checkParm
}

# 一切开始的地方
main $@
````