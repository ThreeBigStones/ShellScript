###################################################################################################
# parameter-analyse.sh:
#    public
#
#Purpose:
#        交互式函数封装
#
#Author:
#    1014263039@qq.com  ---Liu
#
#Creating Time:
#    2021-03-18
###################################################################################################

# 函数功能：
#   移除一个关键功能的时，需要去用户去确认
function removePackage()
{
    echo -e "\033[41mNote:package cannot be remove during installation \033[0m"
    read -r -p "Are you sure remove package? [Y/N]" input
    case $input in
        [yY][eE][sS]|[yY])
            #rm -rf  ...
            ;;

        [nN][oO]|[nN])
            ;;

        *)
            echo "Invalid input..."
            exit 1
            ;;
    esac
}