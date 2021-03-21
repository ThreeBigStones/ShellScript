###################################################################################################
# convert.sh:
#    public
#
#Purpose:
#        转换函数封装
#
#Author:
#    1014263039@qq.com
#
#Creating Time:
#    2021-03-21
###################################################################################################

# 定义返回值
SUCCEEDED=0
ERR_PARAM_NUM=1
ERR_UNIT_IS_INVALID=2
ERR_OBJCOPY=3

# 函数功能：
#   32位大小端转换
# 参数：
#   $1 8位输入转换数据(000009E6)
# 返回
#   输出8位 转换后数据(E6090000)
function endianSwap()
{
    # Check parameter number
    if [ 1 -ne $# ]; then
        return 1
    fi

    # Check whether parameter is hex string with 8 char number
    if ! (echo $1 | grep '^[0-9A-Fa-f]\{8\}$') >/dev/null 2>&1; then
        return 2
    fi

    # Change to little endian and output
    echo -n `echo -n $1 | cut -c 7-8``echo -n $1 | cut -c 5-6``echo -n $1 | cut -c 3-4``echo -n $1 | cut -c 1-2`
}

# 函数功能：
#   十进制转二进制
# 参数：
#   $1: 十进制数(2534)
# 返回
#   16进制数据 (000009E6) (4字节大端序)
function dec2hex()
{
    # Check parameter number
    if [ 1 -ne $# ]; then
        return 1
    fi

    # Check whether parameter is dec string
    if ! (echo $1 | grep '^[0-9]\+$') >/dev/null 2>&1; then
        return 2
    fi

    local OUT=`echo "obase=16;$1" | bc`

    # Add '0'
    local CHAR_NUM=$((8 - `echo -n ${OUT} | wc -c`))
    if [ 0 -gt ${CHAR_NUM} ]; then
        return 3
    else
        local I=0
        while [ $I -lt ${CHAR_NUM} ];
        do
            OUT="0${OUT}"
            I=$((I + 1))
        done
    fi
}

# 函数功能：
#   16进制的字符串，转换成写入文件的2进制流(制作裸镜像使用，可用hexdump查看)
# 参数：
#   $1: 输入16进制数据(A55A5AA5)
# 返回
#  输出结果 直接写入文件的二进制流
echoHex()
{
    # Check parameter number
    if [ 1 -ne $# ]; then
        return 1
    fi

    # Check whether parameter is hex string
    if ! (echo $1 | grep '^[0-9A-Fa-f]\+$') >/dev/null 2>&1; then
        return 2
    fi

    local CHAR_NUM=`echo -n $1 | wc -c`
    # Check char number of hex string
    if [ 0 -ne $((${CHAR_NUM} % 2)) ]; then
        return 3
    fi

    local I=1
    while [ $I -le ${CHAR_NUM} ];
    do
        echo -en "\x`echo $1 | cut -c $I-$((I + 1))`"

        # Next
        I=$((I + 2))
    done
}

# 函数功能
#   容量单位字符分片 (1024B --> 1024 B)
# 参数：
#   $1: Unit: B(1), s(512B), K(1024B), M(1024K), G(1024M), T(1024G)
# 返回：
#   digit & unit
function digitUnitSplit()
{
    if [ 1 -ne $# ]; then
        return ${ERR_PARAM_NUM}
    fi

    local INPUT=$1

    # Input parameter check
    if ! (echo ${INPUT} | grep '^[[:digit:]]\+[BsKMGT]$') >/dev/null 2>&1; then
        return ${ERR_INPUT_IS_INVALID}
    fi

    # Split the digit & unit
    echo `echo ${INPUT} | grep -o '^[[:digit:]]\+'` `echo ${INPUT} | grep -o '[BsKMGT]$'`
}

# 函数功能：
#   1024B K 将1024B换算成多少K，结果是1K
# $1: input with unit
#     Unit: B(1), s(512B), K(1024B), M(1024K), G(1024M), T(1024G)
# $2: output unit
#     Unit: B(1), s(512B), K(1024B), M(1024K), G(1024M), T(1024G)
# ret: output without unit
#      if error, echo nothing
#
# for example:
#   unit_convert 1024B K --> 1
#   unit_convert 1s B --> 512
#
# Note: this function doesn't support float point arithmetic
unitConvert()
{
    if [ 2 -ne $# ]; then
        return ${ERR_PARAM_NUM}
    fi

    local INPUT=`digitUnitSplit $1 | awk '{print $1}'`
    local INPUT_UNIT=`digitUnitSplit $1 | awk '{print $2}'`
    local OUTPUT_UNIT=$2
    local OUTPUT=""

    if [ -z "${INPUT}" -o -z "${INPUT_UNIT}" ]; then
        return ${ERR_INPUT_IS_INVALID}
    fi

    # At first, convert INPUT to bytes
    case ${INPUT_UNIT} in
        B)
            ;;
        s)
            INPUT=$((${INPUT} * 512))
            ;;
        K)
            INPUT=$((${INPUT} * 1024))
            ;;
        M)
            INPUT=$((${INPUT} * 1024 * 1024))
            ;;
        G)
            INPUT=$((${INPUT} * 1024 * 1024 * 1024))
            ;;
        T)
            INPUT=$((${INPUT} * 1024 * 1024 * 1024 * 1024))
            ;;
        *)
            return ${ERR_UNIT_IS_INVALID}
            ;;
    esac

    # Then, convert INPUT to OUTPUT with output unit
    case ${OUTPUT_UNIT} in
        B)
            OUTPUT=${INPUT}
            ;;
        s)
            OUTPUT=$((${INPUT} / 512))
            ;;
        K)
            OUTPUT=$((${INPUT} / 1024))
            ;;
        M)
            OUTPUT=$((${INPUT} / 1024 / 1024))
            ;;
        G)
            OUTPUT=$((${INPUT} / 1024 / 1024 / 1024))
            ;;
        T)
            OUTPUT=$((${INPUT} / 1024 / 1024 / 1024 / 1024))
            ;;
        *)
            return ${ERR_UNIT_IS_INVALID}
            ;;
    esac

    echo ${OUTPUT}
}

# 函数功能
#   s-rec烧录文件转换
# 参数
# $1: input binary file
# $2: output s-rec file
function conv2srec()
{
    if [ 2 -ne $# ]; then
        echo "   Parameter wrong!"
        return ${ERR_PARAM_NUM}
    fi

    local INPUT="$1"
    local OUTPUT="$2"

    echo "Converting temp file into S-REC format: \`${INPUT}' -> \`${OUTPUT}'..."
    
    if ! objcopy -I binary -O srec --srec-forceS3 "${INPUT}" "${OUTPUT}"; then
        echo "   Objcopy wrong!"
        return ${ERR_OBJCOPY}
    fi
}