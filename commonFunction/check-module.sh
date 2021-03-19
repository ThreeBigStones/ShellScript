###################################################################################################
# check-module.sh:
#    public
#
#Purpose:
#        检查模块封装 (命令检查，平台检查等)
#
#Author:
#    1014263039@qq.com  ---Liu
#
#Creating Time:
#    2021-03-20
###################################################################################################
# 函数功能：
#   当前所在磁盘剩余空间检查 (小于5G的时候抛错)
function checkSpace()
{
    local local_left=`df -h ./ | awk '{print $4}' | sed -n '2p' | awk -FG '{print $1}'`
    if [ ${local_left} -lt 5 ]; then
       echoError "no left space!!"
       exit ${FAILED_NO_SPACE}
    fi
}

# 函数功能：
#   命令工具存在性检查
# 参数 $1 系统命令(awk, uname 等)
function checkCmdExist()
{
    type $1 >/dev/null 2>&1
    if [[ $? == 1 ]]; then
        echoError "Command '$1' cannot find, please configure your environment."
        exit 1
    fi
}

# 函数功能：
#   root 权限检查
function detectRootPermission()
{
    if [ ! "$USER" = "root" ]; then
        echoError "Current user is '$USER', you should run as root user."
        exit 1
    fi
}


# 函数功能：
#    IP地址合法性检查(ipv4 255.255.255.255; ipv6 CDCD:910A:2222:5498:8475:1111:3900:2020)
# 参数 $1 ipaddr
function checkIPAddr()
{
    ipv6=0

    echo $1|grep "^[0-9]\{1,3\}\.\([0-9]\{1,3\}\.\)\{2\}[0-9]\{1,3\}$" > /dev/null

    if [ $? -ne 0 ]; then
        if [[ $1 =~ ":" ]]; then
            ipv6=1
        else
            echoError "IP Address $1 is invalid"
            return 1
        fi
    fi

    ipaddr=$1
    if [ $ipv6 -eq 0 ]; then
        a=`echo $ipaddr|awk -F"." '{print $1}'`
        b=`echo $ipaddr|awk -F"." '{print $2}'`
        c=`echo $ipaddr|awk -F"." '{print $3}'`
        d=`echo $ipaddr|awk -F"." '{print $4}'`
        for num in $a $b $c $d
        do
            if [ $num -gt 255 ] || [ $num -lt 0 ]; then
                echoError "IP Address $1 is invalid"
                return 1
            fi
        done
        return 0
    else
        i=1
        while [ $i -le 8 ];
        do
            split=`echo $ipaddr|cut -d ":" -f $i`
            if [[ "$split" != "" ]]; then
                echo $split|grep "[0-9a-fA-F]\{1,4\}" > /dev/null
                if [ $? -ne 0 ]; then
                    echo "IP Address $1 is invalid"
                fi
            fi
            i=$((i + 1))
        done
    fi
}

# 函数功能：
#   平台支持性检查
#  参数 $ 平台信息文件(releaseInfo)
function checkPlatform ()
{
    Architecture=$(uname -p)

    if [ ${Architecture} = "mips64el" ] || [ ${Architecture} = "aarch64" ]; then
        grep -i ${Architecture} $1   &>/dev/null
        if [ $? -ne 0 ]; then
            echoError "Please use the right install environment"
            exit 1
        fi

    elif [ ${Architecture} = "x86_64" ]; then

        Check_suse_ubuntu ()
        {
            Kernel_first=$(uname -r|cut -d"." -f 1)
            Kernel_second=$(uname -r|cut -d"." -f 2)
            if [ ${Kernel_first} -ge 4 ] && [ ${Kernel_second} -ge 4 ];  then
                echo ''
            else
                echoError "Please use the right install environment"
                exit 1
            fi
        }
        
        Check_redhat_centos ()
        {
            Judge_version=$(cat /etc/system-release | grep -i oracle |wc -l)
            Kernel_first=$(uname -r|cut -d"." -f 1)
            Kernel_second=$(uname -r|cut -d"." -f 2)
            GLIBC_first=$(ldd --version|grep ldd|awk -F' ' '{print $4}'|cut -d"." -f1)
            GLIBC_second=$(ldd --version|grep ldd|awk -F' ' '{print $4}'|cut -d"." -f2)
            if [ ${Judge_version} -ne 0 ];then
                if [ ${Kernel_first} -ge 3 ] && [ ${Kernel_second} -ge 1 ] && [ ${GLIBC_first} -ge 2 ] && [ ${GLIBC_second} -ge 17 ];  then
                    echo ''
                else
                    echoError "Please use the right install environment"
                    exit 1
                fi
            else
                if [ ${Kernel_first} -ge 3 ] && [ ${Kernel_second} -ge 10 ] && [ ${GLIBC_first} -ge 2 ] && [ ${GLIBC_second} -ge 17 ];  then
                    echo ''
                else
                    echoError "Please use the right install environment"
                    exit 1
                fi
            fi
        }

        egrep -i "mips64el|aarch64" $1   &>/dev/null
        if [ $? -eq 0 ]; then
            echoError "Please use the right environment"
            exit 1
        fi
        
        type lsb_release  &>/dev/null
        if [ $? -eq 0 ]; then
            Suse_Ubutu=$(lsb_release -a|egrep -i "suse|ubuntu")
            if [ -n "${Suse_Ubutu}" ];  then
                Check_suse_ubuntu
            else
                Check_redhat_centos
            fi         
        else
            Issue_file="/etc/issue"
            if [ -f ${Issue_file} ];  then
                Suse_Ubutu=$(egrep -i "suse|ubuntu" ${Issue_file})
                if [ -n "${Suse_Ubutu}" ];  then
                    Check_suse_ubuntu
                else
                    Check_redhat_centos
                fi 
            fi
        fi
        
    elif [ ${Architecture} = "i686" ];  then
        echoError "32-bit platforms are not supported"
        exit 1
    else
        echo ''
    fi
}

# 函数功能：
#   进程存在性检查
# 参数 $1 进程名称(systemd 等)
function checkProcExists()
{
    local local_proc_num=$(ps -e | grep $1 |wc -l)
    if [ ${local_proc_num} != "0" ] ; then
        echoError "Running proc($1) have been detected, please stop them first!"
        exit 1
    fi

    exit 0
}
