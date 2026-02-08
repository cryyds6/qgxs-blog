#!/bin/bash
set -euo pipefail

# ======================== 基础配置 ========================
# 颜色常量（兼容无颜色终端）
if [ -t 1 ]; then
    MAGENTA='\033[0;1;35;95m'
    RED='\033[0;1;31;91m'
    YELLOW='\033[0;1;33;93m'
    GREEN='\033[0;1;32;92m'
    CYAN='\033[0;1;36;96m'
    BLUE='\033[0;1;34;94m'
    NC='\033[0m'
else
    MAGENTA=''
    RED=''
    YELLOW=''
    GREEN=''
    CYAN=''
    BLUE=''
    NC=''
fi

# Root/普通用户路径适配
if [[ $EUID -eq 0 ]]; then
    DEFAULT_INSTALL_BASE_DIR="/opt/Napcat"  # root用户默认路径
else
    DEFAULT_INSTALL_BASE_DIR="${HOME}/Napcat"  # 普通用户默认路径
fi
INSTALL_BASE_DIR="${DEFAULT_INSTALL_BASE_DIR}"
QQ_BASE_PATH="${INSTALL_BASE_DIR}/opt/QQ"
TARGET_FOLDER="${QQ_BASE_PATH}/resources/app/app_launcher"
QQ_EXECUTABLE="${QQ_BASE_PATH}/qq"
QQ_PACKAGE_JSON_PATH="${QQ_BASE_PATH}/resources/app/package.json"

# 兼容 macOS/BSD 系统的 date 命令
date_cmd="date"
if [[ "$(uname -s)" == "Darwin" ]]; then
    date_cmd="gdate"  # 需要 brew install coreutils
fi

# 全局变量：是否允许root安装
allow_root_install="n"

# ======================== 核心工具函数 ========================
function logo() {
    echo -e " ${MAGENTA}┌${RED}──${YELLOW}──${GREEN}──${CYAN}──${BLUE}──${MAGENTA}──${RED}──${YELLOW}──${GREEN}──${CYAN}──${BLUE}──${MAGENTA}──${RED}──${YELLOW}──${GREEN}──${CYAN}──${BLUE}──${MAGENTA}──${RED}──${YELLOW}──${GREEN}──${CYAN}──${BLUE}──${MAGENTA}──${RED}──${YELLOW}──${GREEN}──${CYAN}──${BLUE}──${MAGENTA}──${RED}──${YELLOW}──${GREEN}──${CYAN}──${BLUE}──${MAGENTA}${RED}─┐${NC}"
    echo -e " ${MAGENTA}│${RED}  ${YELLOW}  ${GREEN}  ${CYAN}  ${BLUE}  ${MAGENTA}  ${RED}  ${YELLOW}  ${GREEN}  ${CYAN}  ${BLUE}  ${MAGENTA}  ${RED}  ${YELLOW}  ${GREEN}  ${CYAN}  ${BLUE}  ${MAGENTA}  ${RED}  ${YELLOW}  ${GREEN}  ${CYAN}  ${BLUE}  ${MAGENTA}  ${RED}  ${YELLOW}  ${GREEN}  ${CYAN}  ${BLUE}  ${MAGENTA}  ${RED}  ${YELLOW}  ${GREEN}  ${CYAN}  ${BLUE}  ${MAGENTA} ${RED}│${NC}"
    echo -e " ${RED}│${YELLOW}██${GREEN}█╗${CYAN}  ${BLUE} █${MAGENTA}█╗${RED}  ${YELLOW}  ${GREEN} █${CYAN}██${BLUE}██${MAGENTA}╗ ${RED}  ${YELLOW}  ${GREEN}██${CYAN}██${BLUE}██${MAGENTA}╗ ${RED}  ${YELLOW}  ${GREEN} █${CYAN}██${BLUE}██${MAGENTA}█╗${RED}  ${YELLOW}  ${GREEN} █${CYAN}██${BLUE}██${MAGENTA}╗ ${RED}  ${YELLOW}  ${GREEN}██${CYAN}██${BLUE}██${MAGENTA}██${RED}╗${YELLOW}│${NC}"
    echo -e " ${YELLOW}│${GREEN}██${CYAN}██${BLUE}╗ ${MAGENTA} █${RED}█║${YELLOW}  ${GREEN}  ${CYAN}██${BLUE}╔═${MAGENTA}═█${RED}█╗${YELLOW}  ${GREEN}  ${CYAN}██${BLUE}╔═${MAGENTA}═█${RED}█╗${YELLOW}  ${GREEN}  ${CYAN}██${BLUE}╔═${MAGENTA}══${RED}═╝${YELLOW}  ${GREEN}  ${CYAN}██${BLUE}╔═${MAGENTA}═█${RED}█╗${YELLOW}  ${GREEN}  ${CYAN}╚═${BLUE}═█${MAGENTA}█╔${RED}══${YELLOW}╝${YELLOW}│${NC}"
    echo -e " ${GREEN}│${CYAN}██${BLUE}╔█${MAGENTA}█╗${RED} █${YELLOW}█║${GREEN}  ${CYAN}  ${BLUE}██${MAGENTA}██${RED}██${YELLOW}█║${GREEN}  ${CYAN}  ${BLUE}██${MAGENTA}██${RED}██${YELLOW}╔╝${GREEN}  ${CYAN}  ${BLUE}██${MAGENTA}║ ${RED}  ${YELLOW}  ${GREEN}  ${CYAN}  ${BLUE}  ${MAGENTA}  ${RED}██${YELLOW}██${GREEN}██${CYAN}█║${BLUE}  ${MAGENTA}  ${RED} █${YELLOW}█║${GREEN}  ${GREEN}│${NC}"
    echo -e " ${CYAN}│${BLUE}██${MAGENTA}║╚${RED}██${YELLOW}╗█${GREEN}█║${CYAN}  ${BLUE}  ${MAGENTA}██${RED}╔═${YELLOW}═█${GREEN}█║${CYAN}  ${BLUE}  ${MAGENTA}██${RED}╔═${YELLOW}══${GREEN}╝ ${CYAN}  ${BLUE}  ${MAGENTA}██${RED}║ ${YELLOW}  ${GREEN}  ${CYAN}  ${BLUE}  ${MAGENTA}  ${RED}██${YELLOW}╔═${GREEN}═█${CYAN}█║${BLUE}  ${MAGENTA}  ${RED} █${YELLOW}█║${GREEN}  ${CYAN} ${CYAN}│${NC}"
    echo -e " ${BLUE}│${MAGENTA}██${RED}║ ${YELLOW}╚█${GREEN}██${CYAN}█║${BLUE}  ${MAGENTA}  ${RED}██${YELLOW}║ ${GREEN} █${CYAN}█║${BLUE}  ${MAGENTA}  ${RED}██${YELLOW}║ ${GREEN}  ${CYAN}  ${BLUE}  ${MAGENTA}  ${RED}  ${YELLOW} ╚${GREEN}██${CYAN}██${BLUE}██${MAGENTA}█╗${RED}  ${YELLOW}  ${GREEN}██${CYAN}║ ${BLUE} █${MAGENTA}█║${RED}  ${YELLOW}  ${GREEN}  ${CYAN} █${BLUE}█║${MAGENTA}  ${BLUE} ${BLUE}│${NC}"
    echo -e " ${MAGENTA}│${RED}╚═${YELLOW}╝ ${GREEN} ╚${CYAN}══${BLUE}═╝${MAGENTA}  ${RED}  ${YELLOW}╚═${GREEN}╝ ${CYAN} ╚${BLUE}═╝${MAGENTA}  ${RED}  ${YELLOW}╚═${GREEN}╝ ${CYAN}  ${BLUE}  ${MAGENTA}  ${RED}  ${YELLOW} ╚${GREEN}══${CYAN}══${BLUE}═╝${MAGENTA}  ${RED}  ${YELLOW}╚═${GREEN}╝ ${CYAN} ╚${BLUE}═╝${MAGENTA}  ${RED}  ${YELLOW}  ${GREEN} ╚${CYAN}═╝${BLUE}  ${MAGENTA} ${MAGENTA}│${NC}"
    echo -e " ${RED}└${YELLOW}──${GREEN}──${CYAN}──${BLUE}──${MAGENTA}──${RED}──${YELLOW}──${GREEN}──${CYAN}──${BLUE}──${MAGENTA}──${RED}──${YELLOW}──${GREEN}──${CYAN}──${BLUE}──${MAGENTA}──${RED}──${YELLOW}──${GREEN}──${CYAN}──${BLUE}──${MAGENTA}──${RED}──${YELLOW}──${GREEN}──${CYAN}──${BLUE}──${MAGENTA}──${RED}──${YELLOW}──${GREEN}──${CYAN}──${BLUE}──${MAGENTA}──${RED}${YELLOW}─┘${NC}"
    echo -e "                      ${BLUE}Powered by NapCat-Installer${NC}\n"
}

function log() {
    time=$(${date_cmd} +"%Y-%m-%d %H:%M:%S")
    message="[${time}]: $1 "
    case "$1" in
    *"失败"* | *"错误"* | *"sudo不存在"* | *"无法连接"*)
        echo -e "${RED}${message}${NC}"
        ;;
    *"成功"*)
        echo -e "${GREEN}${message}${NC}"
        ;;
    *"忽略"* | *"跳过"* | *"默认"* | *"警告"*)
        echo -e "${YELLOW}${message}${NC}"
        ;;
    *)
        echo -e "${BLUE}${message}${NC}"
        ;;
    esac
}

# 增强版命令执行函数
function execute_command() {
    local cmd="$1"
    local desc="$2"
    local allow_fail="${3:-false}"
    
    log "${desc}中..."
    if eval "${cmd}"; then
        log "${desc} (${cmd})成功"
        return 0
    else
        local exit_code=$?
        if [ "${allow_fail}" = "true" ]; then
            log "${YELLOW}${desc} (${cmd})失败(退出码:${exit_code})，但允许继续${NC}"
            return ${exit_code}
        else
            log "${desc} (${cmd})失败(退出码:${exit_code})"
            exit 1
        fi
    fi
}

# 系统兼容性检查
function check_system_compatibility() {
    local os=$(uname -s)
    local arch=$(uname -m)
    
    log "检测系统环境: OS=${os}, ARCH=${arch}, EUID=${EUID}"
    
    # 兼容 macOS
    if [ "${os}" = "Darwin" ]; then
        log "警告: macOS 系统仅支持 Docker 安装模式，Shell 安装可能无法运行"
        if ! command -v gdate &>/dev/null; then
            log "需要安装 coreutils 以兼容 date 命令"
            execute_command "brew install coreutils" "安装 coreutils" true
        fi
    fi
    
    # 兼容 ARM 架构
    if [[ "${arch}" =~ arm64|aarch64 ]]; then
        log "检测到 ARM 架构，自动适配下载链接"
    elif [[ "${arch}" =~ x86_64|amd64 ]]; then
        log "检测到 x86_64 架构"
    else
        log "错误: 不支持的架构 ${arch}，仅支持 x86_64/arm64"
        exit 1
    fi
}

# ======================== 代理优化（核心修复curl参数）========================
function network_test() {
    local parm1=${1}
    local found=0
    local timeout=15  # 延长超时时间
    local status=0
    target_proxy=""

    local current_proxy_setting="${proxy_num_arg:-auto}"

    log "开始网络测试: ${parm1}..."
    log "命令行传入代理参数 (proxy_num_arg): '${proxy_num_arg}', 本次测试生效设置: '${current_proxy_setting}'"

    # 国内可用代理列表
    if [ "${parm1}" == "Github" ]; then
        proxy_arr=(
            "https://mirror.ghproxy.com"          
            "https://gh-proxy.com"               
            "https://gh.api.99988866.xyz"        
            "https://github.moeyy.cn"            
            "https://git.xiaozhuo.me"            
        )
        check_url="https://raw.githubusercontent.com/NapNeko/NapCatQQ/main/package.json"
    elif [ "${parm1}" == "Docker" ]; then
        proxy_arr=(
            "https://dockerproxy.com"            
            "https://docker.m.daocloud.io"       
            "https://mirror.baidubce.com"        
            "https://hub-mirror.c.163.com"       
        )
        check_url=""
    else
        log "错误: 未知的网络测试目标 '${parm1}', 默认测试 Github"
        parm1="Github"
        proxy_arr=(
            "https://mirror.ghproxy.com"
            "https://gh-proxy.com"
            "https://gh.api.99988866.xyz"
        )
        check_url="https://raw.githubusercontent.com/NapNeko/NapCatQQ/main/package.json"
    fi

    # 手动指定代理
    if [[ "${current_proxy_setting}" =~ ^[0-9]+$ && "${current_proxy_setting}" -ge 1 && "${current_proxy_setting}" -le ${#proxy_arr[@]} ]]; then
        log "手动指定代理: ${proxy_arr[$((current_proxy_setting - 1))]}"
        target_proxy="${proxy_arr[$((current_proxy_setting - 1))]}"
    elif [ "${current_proxy_setting}" == "0" ]; then
        log "代理已关闭, 尝试直连 ${parm1}..."
        target_proxy=""
        if [ -n "${check_url}" ]; then
            # 核心修复：curl -w "%{http_code}:%{exitcode}" （添加%{}）
            status_and_exit_code=$(curl -k --connect-timeout ${timeout} --max-time $((timeout * 2)) --retry 2 -o /dev/null -s -w "%{http_code}:%{exitcode}" "${check_url}")
            status=$(echo "${status_and_exit_code}" | cut -d: -f1)
            curl_exit_code=$(echo "${status_and_exit_code}" | cut -d: -f2)
            if [ "${curl_exit_code}" -eq 0 ] && [ "${status}" -eq 200 ]; then
                log "直连 ${parm1} (${check_url}) 测试成功。"
            else
                log "警告: 直连 ${parm1} 失败 (HTTP状态: ${status}, curl退出码: ${curl_exit_code})"
            fi
        fi
    else
        log "自动测试 ${parm1} 代理可用性并测速..."
        local best_proxy=""
        local best_speed=0

        # 先测试直连
        if [ -n "${check_url}" ]; then
            log "测速: 直连..."
            # 核心修复：curl -w "%{http_code}:%{exitcode}:%{speed_download}"
            local curl_output
            curl_output=$(curl -k -L --connect-timeout ${timeout} --max-time $((timeout * 3)) --retry 1 -o /dev/null -s -w "%{http_code}:%{exitcode}:%{speed_download}" "${check_url}")
            local status=$(echo "${curl_output}" | cut -d: -f1)
            local curl_exit_code=$(echo "${curl_output}" | cut -d: -f2)
            local download_speed=$(echo "${curl_output}" | cut -d: -f3 | cut -d. -f1)

            if [ "${curl_exit_code}" -eq 0 ] && [ "${status}" -eq 200 ]; then
                local formatted_speed=$(format_speed "${download_speed}")
                log "测速: 直连 - ${formatted_speed}"
                best_speed=${download_speed}
            else
                log "直连测试失败或超时。"
            fi
        fi

        # 测试代理（并行测速）
        local proxy_speeds=()
        for proxy_candidate in "${proxy_arr[@]}"; do
            local test_target_url
            if [ -n "${check_url}" ]; then
                test_target_url="${proxy_candidate}/${check_url}"
            else
                test_target_url="${proxy_candidate}/"
            fi

            # 后台测速（核心修复curl参数）
            (
                local curl_output=$(curl -k -L --connect-timeout ${timeout} --max-time $((timeout * 3)) --retry 1 -o /dev/null -s -w "%{http_code}:%{exitcode}:%{speed_download}" "${test_target_url}")
                local status=$(echo "${curl_output}" | cut -d: -f1)
                local curl_exit_code=$(echo "${curl_output}" | cut -d: -f2)
                local download_speed=$(echo "${curl_output}" | cut -d: -f3 | cut -d. -f1)

                if [ "${curl_exit_code}" -eq 0 ] && ( [ "${parm1}" == "Github" ] && [ "${status}" -eq 200 ] || [ "${parm1}" == "Docker" ] && ( [ "${status}" -eq 200 ] || [ "${status}" -eq 301 ] || [ "${status}" -eq 302 ] ) ); then
                    local formatted_speed=$(format_speed "${download_speed}")
                    echo "${proxy_candidate}|${download_speed}|${formatted_speed}"
                fi
            ) &
        done

        # 收集测速结果
        wait
        while read -r line; do
            if [ -n "${line}" ]; then
                local proxy=$(echo "${line}" | cut -d| -f1)
                local speed=$(echo "${line}" | cut -d| -f2)
                local f_speed=$(echo "${line}" | cut -d| -f3)
                log "测速: ${proxy} - ${f_speed}"
                if [[ ${speed} -gt ${best_speed} ]]; then
                    best_speed=${speed}
                    best_proxy=${proxy}
                fi
            fi
        done < <(jobs -p | xargs -I {} wait {}; cat)

        # 确定最优代理
        if [[ ${best_speed} -gt 0 ]]; then
            found=1
            target_proxy="${best_proxy}"
            local formatted_best_speed=$(format_speed "${best_speed}")
            if [ -n "${best_proxy}" ]; then
                log "使用最快代理: ${target_proxy} (速度: ${formatted_best_speed})"
            else
                log "直连速度最快 (速度: ${formatted_best_speed})"
            fi
        else
            log "警告: 无可用代理且直连失败，将尝试使用第一个代理"
            target_proxy="${proxy_arr[0]}"
        fi
    fi
}

# 速度格式化
function format_speed() {
    local speed_bps=$1
    if ! [[ "${speed_bps}" =~ ^[0-9]+$ ]]; then
        echo "0 B/s"
        return
    fi
    
    if (( speed_bps > 1048576 )); then
        local speed_mbs=$(echo "scale=2; ${speed_bps} / 1048576" | bc)
        echo "${speed_mbs} MB/s"
    elif (( speed_bps > 1024 )); then
        local speed_kbs=$(echo "scale=2; ${speed_bps} / 1024" | bc)
        echo "${speed_kbs} KB/s"
    else
        echo "${speed_bps} B/s"
    fi
}

# ======================== Root权限选择 ========================
function choose_root_permission() {
    log "===== 权限选择 ====="
    if [[ $EUID -eq 0 ]]; then
        log "警告: 当前以ROOT用户运行，使用root安装可能导致权限问题！"
        read -p "是否确认使用ROOT权限安装? (y/N): " confirm_root
        if [[ "${confirm_root}" =~ ^[Yy]$ ]]; then
            allow_root_install="y"
            log "已确认使用ROOT权限安装，安装路径: ${INSTALL_BASE_DIR}"
        else
            log "请切换到普通用户后重新执行脚本！"
            exit 1
        fi
    else
        read -p "是否要切换到ROOT权限安装? (N/y): " switch_root
        if [[ "${switch_root}" =~ ^[Yy]$ ]]; then
            if ! command -v sudo &>/dev/null; then
                log "错误: 系统未安装sudo，无法切换root权限！"
                exit 1
            fi
            log "将切换到ROOT权限重新执行脚本..."
            exec sudo bash "${0}" "$@"
        else
            allow_root_install="n"
            log "将使用普通用户权限安装，安装路径: ${INSTALL_BASE_DIR}"
        fi
    fi
}

# ======================== 依赖检查与安装 ========================
function check_sudo() {
    if ! command -v sudo &>/dev/null; then
        log "sudo不存在, 尝试自动安装..."
        detect_package_manager
        if [ "${package_manager}" = "apt-get" ]; then
            execute_command "apt-get update -y -qq && apt-get install -y -qq sudo" "安装sudo" true
        elif [ "${package_manager}" = "dnf" ]; then
            execute_command "dnf install -y sudo" "安装sudo" true
        else
            log "请手动安装sudo:
Centos: dnf install -y sudo
Debian/Ubuntu: apt-get install -y sudo"
            exit 1
        fi
    fi
}

function detect_package_manager() {
    if command -v apt-get &>/dev/null; then
        package_manager="apt-get"
        package_installer="dpkg"
    elif command -v dnf &>/dev/null; then
        package_manager="dnf"
        package_installer="rpm"
        dnf_is_el_or_fedora
    elif command -v yum &>/dev/null; then
        package_manager="yum"
        package_installer="rpm"
        dnf_host="el"
    elif command -v brew &>/dev/null; then
        package_manager="brew"
        package_installer="brew"
    else
        log "不支持的包管理器，仅支持 apt-get/dnf/yum/brew"
        exit 1
    fi
    log "当前包管理器: ${package_manager}, 安装器: ${package_installer}"
}

function check_whiptail() {
    local term_type="${TERM:-xterm}"
    if [[ "${term_type}" != "xterm" && "${term_type}" != "xterm-256color" && "${term_type}" != "screen" && "${term_type}" != "screen-256color" ]]; then
        log "警告: 终端类型 ${term_type} 可能不兼容 whiptail，建议切换到 xterm"
        read -p "是否继续使用 whiptail? (y/N): " confirm
        if [[ ! "${confirm}" =~ ^[Yy]$ ]]; then
            log "退出 TUI 模式，使用命令行模式"
            exit 0
        fi
    fi

    if ! command -v whiptail &>/dev/null; then
        log "未发现whiptail, 开始安装..."
        detect_package_manager
        if [ "${package_manager}" = "apt-get" ]; then
            execute_command "sudo apt-get update -y -qq && sudo apt-get install -y -qq whiptail" "安装whiptail"
        elif [ "${package_manager}" = "dnf" ] || [ "${package_manager}" = "yum" ]; then
            execute_command "sudo ${package_manager} install -y epel-release && sudo ${package_manager} install -y whiptail" "安装whiptail"
        elif [ "${package_manager}" = "brew" ]; then
            execute_command "brew install newt" "安装 newt (whiptail)" true
        fi
    fi
}

function install_dependency() {
    log "开始安装系统依赖..."
    detect_package_manager

    if [ "${package_manager}" = "apt-get" ]; then
        execute_command "sudo apt-get update -y -qq" "更新软件包列表" true
        local static_pkgs="zip unzip jq curl xvfb screen xauth procps rpm2cpio cpio libnss3 libgbm1"
        local pkgs_to_check=(
            "libglib2.0-0"
            "libatk1.0-0"
            "libatspi2.0-0"
            "libgtk-3-0"
            "libasound2"
        )
        
        local resolved_pkgs=()
        for pkg_base in "${pkgs_to_check[@]}"; do
            local t64_variant="${pkg_base}t64"
            if apt-cache show "${t64_variant}" >/dev/null 2>&1; then
                resolved_pkgs+=("${t64_variant}")
            else
                resolved_pkgs+=("${pkg_base}")
            fi
        done

        local all_pkgs_to_install="${static_pkgs} ${resolved_pkgs[*]}"
        execute_command "sudo apt-get install -y -qq ${all_pkgs_to_install}" "安装依赖" true

    elif [ "${package_manager}" = "dnf" ] || [ "${package_manager}" = "yum" ]; then
        if [ "${dnf_host}" = "el" ]; then
            install_el_repo
        fi
        enable_dnf_repos_and_cache
        local base_pkgs="zip unzip jq curl screen procps-ng cpio nss mesa-libgbm atk at-spi2-atk gtk3 alsa-lib pango cairo libdrm libXcursor libXrandr libXdamage libXcomposite libXfixes libXrender libXi libXtst libXScrnSaver cups-libs libxkbcommon"
        local x_extra="libX11-xcb"
        local mesa_extra="mesa-dri-drivers mesa-libEGL mesa-libGL"
        local xcb_utils="xcb-util xcb-util-image xcb-util-wm xcb-util-keysyms xcb-util-renderutil"
        local fonts="fontconfig dejavu-sans-fonts"
        local xvfb_pkg="xorg-x11-server-Xvfb"
        local all_pkgs="${base_pkgs} ${x_extra} ${mesa_extra} ${xcb_utils} ${fonts} ${xvfb_pkg}"

        execute_command "sudo ${package_manager} install --allowerasing -y ${all_pkgs}" "安装依赖" true

    elif [ "${package_manager}" = "brew" ]; then
        log "macOS 系统，仅安装基础依赖"
        execute_command "brew install curl jq zip unzip screen" "安装基础依赖" true
    fi
    log "依赖安装完成"
}

# 移除root安装限制
function check_root_for_shell_install() {
    if [[ $EUID -eq 0 && "${allow_root_install}" != "y" ]]; then
        log "警告: 不推荐使用root权限执行Shell安装"
        echo -e "${YELLOW}如果是旧版本升级，请使用普通用户重新安装${NC}"
    else
        log "已确认使用root权限安装，跳过权限警告"
    fi
}

function print_introduction() {
    echo -e "${BLUE}下面是 NapCat 安装脚本的功能简介！${NC}😋"
    echo -e "${BLUE}--${NC}"
    echo -e "${BLUE}接下来，您可以选择安装方式:${NC}"
    echo -e "  1. ${GREEN}Docker 安装${NC}: ${BLUE}通过容器运行 (需要 root 或 docker 用户组权限)。${NC}"
    echo -e "  2. ${GREEN}本地安装 (支持Root/普通用户)${NC}: ${BLUE}直接在本系统安装，可选择Root/普通用户权限。${NC}(${YELLOW}默认${NC})${NC}"
    echo -e "  	 - ${GREEN}可视化安装${NC}: ${BLUE}通过交互式界面来引导你安装。${NC}"
    echo -e "  	 - ${GREEN}Shell 安装${NC}: ${BLUE}直接在当前Shell会话执行安装。${NC}(${YELLOW}默认${NC})${NC}"
    echo ""
    echo -e "${BLUE}您可以选择安装的组件方式:${NC}"
    echo -e "  - ${CYAN}NapCat TUI-CLI${NC}: ${BLUE}允许你在 ssh、没有桌面、WebUI 难以使用的情况下可视化交互配置 Napcat${NC}"
    echo ""
    echo -e "${BLUE}使用 --help 来获取更多功能介绍${NC}"
    echo -e "${BLUE}--${NC}"
}

function check_root() {
    if [[ $EUID -ne 0 ]]; then
        log "错误: 此操作需要以 root 权限运行。"
        log "请尝试使用 'sudo bash ${0}' 或切换到 root 用户后运行。"
        exit 1
    fi
    log "脚本正在以 root 权限运行。"
}

function get_system_arch() {
    system_arch=$(uname -m | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
    if [ -z "${system_arch}" ]; then
        log "无法识别的系统架构"
        exit 1
    fi
    log "当前系统架构: ${system_arch}"
}

function dnf_is_el_or_fedora() {
    if [ -f "/etc/fedora-release" ]; then
        dnf_host="fedora"
    else
        dnf_host="el"
    fi
}

function install_el_repo() {
    if [ -f "/etc/opencloudos-release" ]; then
        os_version=$(grep -oE '[0-9]+' /etc/opencloudos-release | head -n 1)
        if [[ -n "$os_version" && "$os_version" -ge 9 ]]; then
            log "检测到 OpenCloudOS 9+, 安装 epol-release..."
            execute_command "sudo dnf install -y epol-release" "安装epol"
        else
            log "OpenCloudOS 版本低于 9, 安装 epel-release..."
            execute_command "sudo dnf install -y epel-release" "安装epel"
        fi
    else
        log "安装 epel-release..."
        execute_command "sudo dnf install -y epel-release" "安装epel"
    fi
}

function enable_dnf_repos_and_cache() {
    log "检查并配置 dnf 仓库..."
    if ! rpm -q dnf-plugins-core >/dev/null 2>&1; then
        execute_command "sudo dnf install -y dnf-plugins-core" "安装 dnf-plugins-core"
    fi

    if dnf repolist all | grep -q '^appstream\s'; then
        if dnf repolist disabled | grep -q '^appstream\s'; then
            execute_command "sudo dnf config-manager --set-enabled appstream" "启用 AppStream 仓库"
        else
            log "AppStream 仓库已启用。"
        fi
    else
        log "警告: 未检测到 appstream 仓库"
    fi

    execute_command "sudo dnf makecache --refresh" "刷新 dnf 缓存"
}

function uninstall_old_version() {
    log "检查旧版本安装..."
    local old_paths=(
        "/opt/QQ"
        "${HOME}/Napcat/opt/QQ"
        "/opt/Napcat/opt/QQ"
    )
    local old_path_found=""
    for path in "${old_paths[@]}"; do
        if [ -d "${path}/resources/app/app_launcher/napcat" ]; then
            old_path_found="${path}"
            break
        fi
    done

    if [ -n "${old_path_found}" ]; then
        log "检测到旧版本安装路径: ${old_path_found}"
        log "警告: 将卸载 'linuxqq' 并删除旧版本目录"
        read -p "是否继续? (y/N): " confirm_delete
        
        if [[ ! "${confirm_delete}" =~ ^[Yy]$ ]]; then
            log "取消操作"
            exit 1
        fi

        detect_package_manager
        if [ "${package_manager}" = "apt-get" ]; then
            execute_command "sudo apt-get remove -y -qq linuxqq" "卸载旧版 linuxqq" true
        elif [ "${package_manager}" = "dnf" ] || [ "${package_manager}" = "yum" ]; then
            execute_command "sudo ${package_manager} remove -y linuxqq" "卸载旧版 linuxqq" true
        fi

        for path in "${old_paths[@]}"; do
            if [ -d "${path}" ]; then
                execute_command "sudo rm -rf ${path}" "清理旧版QQ目录: ${path}" true
            fi
        done
        log "旧版本卸载完成。"
    else
        log "未检测到旧版本, 跳过卸载。"
    fi
}

function create_tmp_folder() {
    local tmp_dir="./NapCat"
    if [ -d "${tmp_dir}" ] && [ "$(ls -A ${tmp_dir})" ]; then
        log "文件夹 ${tmp_dir} 已存在且不为空，请重命名后重试"
        exit 1
    fi
    mkdir -p "${tmp_dir}"
    chmod 755 "${tmp_dir}"
}

function clean() {
    rm -rf ./NapCat || log "临时目录删除失败, 请手动删除 ./NapCat"
    rm -rf ./NapCat.Shell.zip || log "压缩包删除失败, 请手动删除"
    rm -f ./QQ.deb ./QQ.rpm
    if [ -d "${TARGET_FOLDER}/napcat.packet" ]; then
        if [[ $EUID -eq 0 ]]; then
            rm -rf "${TARGET_FOLDER}/napcat.packet"
        else
            sudo rm -rf "${TARGET_FOLDER}/napcat.packet" || log "清理napcat.packet失败，请手动删除"
        fi
    fi
}

function download_napcat() {
    create_tmp_folder
    default_file="NapCat.Shell.zip"
    if [ -f "${default_file}" ]; then
        log "检测到已下载安装包,跳过下载..."
    else
        log "开始下载NapCat安装包..."
        network_test "Github"
        napcat_download_url="${target_proxy:+${target_proxy}/}https://github.com/NapNeko/NapCatQQ/releases/latest/download/NapCat.Shell.zip"

        execute_command "curl -k -L -# --retry 3 ${napcat_download_url} -o ${default_file}" "下载安装包" false

        if [ -f "${default_file}" ]; then
            log "${default_file} 下载成功。"
        else
            ext_file=$(basename "${napcat_download_url}")
            if [ -f "${ext_file}" ]; then
                execute_command "mv ${ext_file} ${default_file}" "文件更名" false
                log "${default_file} 重命名成功。"
            else
                log "文件下载失败, 请手动下载到脚本同目录"
                clean
                exit 1
            fi
        fi
    fi

    log "验证 ${default_file}..."
    execute_command "unzip -t ${default_file} >/dev/null 2>&1" "验证文件" false

    log "解压 ${default_file}..."
    execute_command "unzip -q -o -d ./NapCat NapCat.Shell.zip" "解压文件" false
}

function get_qq_target_version() {
    linuxqq_target_version="3.2.25-45758"
}

function compare_linuxqq_versions() {
    local ver1="${1}"
    local ver2="${2}"

    IFS='.-' read -r -a ver1_parts <<<"${ver1}"
    IFS='.-' read -r -a ver2_parts <<<"${ver2}"

    local length=${#ver1_parts[@]}
    if [ ${#ver2_parts[@]} -lt $length ]; then
        length=${#ver2_parts[@]}
    fi

    for ((i = 0; i < length; i++)); do
        if ((ver1_parts[i] > ver2_parts[i])); then
            force="n"
            return
        elif ((ver1_parts[i] < ver2_parts[i])); then
            force="y"
            return
        fi
    done

    if [ ${#ver1_parts[@]} -gt ${#ver2_parts[@]} ]; then
        force="n"
    elif [ ${#ver1_parts[@]} -lt ${#ver2_parts[@]} ]; then
        force="y"
    else
        force="n"
    fi
}

function check_linuxqq() {
    get_qq_target_version
    local napcat_config_path="${TARGET_FOLDER}/napcat/config"
    local backup_path="/tmp/napcat_config_backup_$(${date_cmd} +%s)"

    if [[ -z "${linuxqq_target_version}" ]]; then
        log "无法获取目标QQ版本"
        exit 1
    fi

    log "目标LinuxQQ版本: ${linuxqq_target_version}"

    local qq_installed=false
    if [ -f "${QQ_PACKAGE_JSON_PATH}" ]; then
        qq_installed=true
        linuxqq_installed_version=$(jq -r '.version' "${QQ_PACKAGE_JSON_PATH}")
        log "检测到已安装QQ版本: ${linuxqq_installed_version}"
        compare_linuxqq_versions "${linuxqq_installed_version}" "${linuxqq_target_version}"
    else
        log "未检测到已安装的QQ"
        force="y"
    fi

    if [ "${force}" = "y" ]; then
        log "执行全新安装/重装..."
        local backup_created=false

        if [ "${qq_installed}" = true ] && [ -d "${napcat_config_path}" ]; then
            log "备份Napcat配置..."
            if mkdir -p "${backup_path}"; then
                if cp -a "${napcat_config_path}/." "${backup_path}/"; then
                    log "配置备份成功: ${backup_path}"
                    backup_created=true
                else
                    log "警告: 配置备份失败"
                fi
            fi
        fi

        if [ -d "${INSTALL_BASE_DIR}" ]; then
            log "移除旧安装目录: ${INSTALL_BASE_DIR}"
            rm -rf "${INSTALL_BASE_DIR}"
        fi

        install_linuxqq_rootless

        if [ "${backup_created}" = true ]; then
            log "恢复配置..."
            if mkdir -p "${napcat_config_path}"; then
                cp -a "${backup_path}/." "${napcat_config_path}/" || log "配置恢复失败"
            fi
            rm -rf "${backup_path}"
        fi
    else
        log "版本已满足要求, 无需更新。"
        update_linuxqq_config "${linuxqq_installed_version}"
    fi
}

function install_linuxqq_rootless() {
    get_system_arch
    log "安装 LinuxQQ 到 ${INSTALL_BASE_DIR}..."

    local qq_download_url=""
    local qq_package_file=""

    if [ "${system_arch}" = "amd64" ]; then
        if [ "${package_installer}" = "rpm" ]; then
            qq_download_url="https://dldir1.qq.com/qqfile/qq/QQNT/7516007c/linuxqq_3.2.25-45758_x86_64.rpm"
            qq_package_file="QQ.rpm"
        elif [ "${package_installer}" = "dpkg" ]; then
            qq_download_url="https://dldir1.qq.com/qqfile/qq/QQNT/7516007c/linuxqq_3.2.25-45758_amd64.deb"
            qq_package_file="QQ.deb"
        fi
    elif [ "${system_arch}" = "arm64" ]; then
        if [ "${package_installer}" = "rpm" ]; then
            qq_download_url="https://dldir1.qq.com/qqfile/qq/QQNT/7516007c/linuxqq_3.2.25-45758_aarch64.rpm"
            qq_package_file="QQ.rpm"
        elif [ "${package_installer}" = "dpkg" ]; then
            qq_download_url="https://dldir1.qq.com/qqfile/qq/QQNT/7516007c/linuxqq_3.2.25-45758_arm64.deb"
            qq_package_file="QQ.deb"
        fi
    fi

    if [ -z "${qq_download_url}" ]; then
        log "获取QQ下载链接失败, 架构不支持"
        exit 1
    fi

    if ! [ -f "${qq_package_file}" ]; then
        log "QQ下载链接: ${qq_download_url}"
        execute_command "curl -k -L -# --retry 3 ${qq_download_url} -o ${qq_package_file}" "下载QQ安装包" false
    else
        log "使用本地QQ安装包"
    fi

    log "创建安装目录: ${INSTALL_BASE_DIR}"
    mkdir -p "${INSTALL_BASE_DIR}"

    log "解压QQ文件..."
    if [ "${package_installer}" = "dpkg" ]; then
        execute_command "dpkg -x ./${qq_package_file} ${INSTALL_BASE_DIR}" "解压QQ (.deb)"
    elif [ "${package_installer}" = "rpm" ]; then
        rpm2cpio "${PWD}/${qq_package_file}" | (cd "${INSTALL_BASE_DIR}" && cpio -idmv)
        if [ $? -eq 0 ]; then
            log "解压QQ (.rpm)成功"
        else
            log "解压QQ (.rpm)失败"
            exit 1
        fi
    fi

    rm -f "${qq_package_file}"
    update_linuxqq_config "${linuxqq_target_version}"
}

function update_linuxqq_config() {
    log "更新QQ配置..."
    local target_ver="${1}"
    local build_id="${target_ver##*-}"
    local user_config_dir
    if [[ $EUID -eq 0 ]]; then
        user_config_dir="/root/.config/QQ/versions"
    else
        user_config_dir="${HOME}/.config/QQ/versions"
    fi
    local user_config_file="${user_config_dir}/config.json"

    if [ -d "${user_config_dir}" ]; then
        if [ -f "${user_config_file}" ]; then
            log "修改 ${user_config_file}..."
            jq --arg targetVer "${target_ver}" --arg buildId "${build_id}" \
                '.baseVersion = $targetVer | .curVersion = $targetVer | .buildId = $buildId' "${user_config_file}" >"${user_config_file}.tmp" &&
                mv "${user_config_file}.tmp" "${user_config_file}" || log "QQ配置更新失败"
        else
            log "未找到配置文件 ${user_config_file}, 首次启动会自动创建"
        fi
    else
        log "未找到配置目录 ${user_config_dir}, 首次启动会自动创建"
    fi
    log "QQ配置更新完成。"
}

function check_napcat() {
    log "安装/覆盖最新NapCat..."
    install_napcat
}

function install_napcat() {
    if [ ! -d "${TARGET_FOLDER}/napcat" ]; then
        mkdir -p "${TARGET_FOLDER}/napcat/"
    fi

    log "移动文件..."
    cp -r -f ./NapCat/* "${TARGET_FOLDER}/napcat/" || {
        log "文件移动失败"
        clean
        exit 1
    }
    log "移动文件成功"

    if [[ $EUID -eq 0 ]]; then
        chmod -R 755 "${TARGET_FOLDER}/napcat/"
    else
        chmod -R +x "${TARGET_FOLDER}/napcat/"
    fi
    log "修补文件..."
    echo "(async () => {await import('file:///${TARGET_FOLDER}/napcat/napcat.mjs');})();" > "${QQ_BASE_PATH}/resources/app/loadNapCat.js" || {
        log "loadNapCat.js写入失败"
        clean
        exit 1
    }
    log "修补文件成功"
    modify_qq_config
    clean
}

function modify_qq_config() {
    log "修改QQ启动配置..."
    if jq '.main = "./loadNapCat.js"' "${QQ_PACKAGE_JSON_PATH}" >./package.json.tmp; then
        mv ./package.json.tmp "${QQ_PACKAGE_JSON_PATH}"
        log "修改QQ启动配置成功"
    else
        log "修改QQ启动配置失败"
        exit 1
    fi
}

function check_napcat_cli() {
    if [ "${use_cli}" = "y" ]; then
        if [ -f "/usr/local/bin/napcat" ]; then
            log "更新 TUI-CLI..."
            install_napcat_cli
            log "TUI-CLI 更新成功。"
        else
            log "安装 TUI-CLI..."
            install_napcat_cli
            log "TUI-CLI 安装成功。"
        fi
    else
        log "跳过 TUI-CLI 安装。"
    fi
}

function install_napcat_cli() {
    local cli_script_url_base="https://raw.githubusercontent.com/NapNeko/NapCat-TUI-CLI/main/script"
    local cli_script_name="install-cli.sh"
    local cli_script_local_path="./${cli_script_name}.download"
    local cli_script_url="${target_proxy:+${target_proxy}/}${cli_script_url_base}/${cli_script_name}"

    if [ -z "${target_proxy+x}" ]; then
        network_test "Github"
    fi

    log "下载 TUI-CLI 安装脚本: ${cli_script_url}"
    execute_command "sudo curl -k -L -# --retry 3 ${cli_script_url} -o ${cli_script_local_path}" "下载CLI脚本" true

    execute_command "sudo chmod +x ${cli_script_local_path}" "设置CLI脚本权限" true

    log "执行 TUI-CLI 安装脚本..."
    sudo "${cli_script_local_path}" "${proxy_num_arg:-9}"
    local exit_status=$?

    if [ ${exit_status} -ne 0 ]; then
        log "TUI-CLI 安装失败 (退出码: ${exit_status})"
    else
        log "TUI-CLI 安装成功"
    fi

    sudo rm -f "${cli_script_local_path}"
    return ${exit_status}
}

function generate_docker_command() {
    local qq=${1}
    local mode=${2}

    if [[ "${mode}" != "ws" && "${mode}" != "reverse_ws" && "${mode}" != "reverse_http" ]]; then
        log "错误: 无效的运行模式 '${mode}'"
        return 1
    fi

    docker_cmd1="sudo docker run -d -e ACCOUNT=${qq}"
    docker_cmd2="--name napcat --restart=always ${target_proxy:+${target_proxy}/}mlikiowa/napcat-docker:latest"
    docker_ws="${docker_cmd1} -e WS_ENABLE=true -e NAPCAT_GID=$(id -g) -e NAPCAT_UID=$(id -u) -p 3001:3001 -p 6099:6099 ${docker_cmd2}"
    docker_reverse_ws="${docker_cmd1} -e WSR_ENABLE=true -e NAPCAT_GID=$(id -g) -e NAPCAT_UID=$(id -u) -p 6099:6099 ${docker_cmd2}"
    docker_reverse_http="${docker_cmd1} -e HTTP_ENABLE=true -e NAPCAT_GID=$(id -g) -e NAPCAT_UID=$(id -u) -p 3000:3000 -p 6099:6099 ${docker_cmd2}"

    if [ "${mode}" = "ws" ]; then
        echo "${docker_ws}"
        return 0
    elif [ "${mode}" = "reverse_ws" ]; then
        echo "${docker_reverse_ws}"
        return 0
    elif [ "${mode}" = "reverse_http" ]; then
        echo "${docker_reverse_http}"
        return 0
    else
        return 1
    fi
}

function get_qq() {
    while true; do
        qq=$(whiptail --title "Napcat Installer" --inputbox "请输入QQ号:" 10 50 3>&1 1>&2 2>&3)

        if [ $? -eq 0 ]; then
            if [ -z "${qq}" ]; then
                whiptail --title "错误" --msgbox "QQ号不能为空" 10 30
            else
                get_mode
                break
            fi
        else
            break
        fi
    done
}

function get_mode() {
    while true; do
        mode=$(whiptail --title "选择模式" --menu "请选择运行模式:" 15 50 3 \
            "ws" "WebSocket 模式" \
            "reverse_ws" "反向 WebSocket 模式" \
            "reverse_http" "反向 HTTP 模式" 3>&1 1>&2 2>&3)

        if [ $? -eq 0 ]; then
            if [ -z "${mode}" ]; then
                whiptail --title "错误" --msgbox "模式选择不能为空" 10 30
            else
                get_confirm
                break
            fi
        else
            break
        fi
    done
}

function get_confirm() {
    if (whiptail --title "确认" --yesno "QQ号: ${qq}\n模式: ${mode}\n是否继续?" 15 50); then
        confirm="y"
        docker_install
    else
        return
    fi
}

function docker_install() {
    if ! command -v docker &>/dev/null; then
        detect_package_manager
        if [ "${package_manager}" = "apt-get" ]; then
            execute_command "sudo apt-get update -y -qq && sudo apt-get install -y -qq curl" "安装curl" true
        elif [ "${package_manager}" = "dnf" ] || [ "${package_manager}" = "yum" ]; then
            execute_command "sudo ${package_manager} install -y curl" "安装curl" true
        elif [ "${package_manager}" = "brew" ]; then
            execute_command "brew install docker" "安装docker" true
        fi
        execute_command "sudo curl -k -fsSL https://get.docker.com -o get-docker.sh" "下载docker安装脚本" true
        sudo chmod +x get-docker.sh
        execute_command "sudo sh get-docker.sh" "安装docker" true
    else
        log "Docker已安装"
    fi

    while true; do
        if [[ -z ${qq} ]]; then
            log "请输入QQ号: "
            read -r qq
            if [[ -z ${qq} ]]; then
                log "QQ号不能为空"
                continue
            fi
        fi

        if [[ -z ${mode} ]]; then
            log "请选择模式 (ws/reverse_ws/reverse_http): "
            read -r mode
            if [[ "${mode}" != "ws" && "${mode}" != "reverse_ws" && "${mode}" != "reverse_http" ]]; then
                log "错误: 无效模式"
                mode=""
                continue
            fi
        fi

        log "生成Docker命令..."
        network_test "Docker"
        docker_command=$(generate_docker_command "${qq}" "${mode}")
        cmd_status=$?

        if [[ $cmd_status -ne 0 || -z ${docker_command} ]]; then
            log "命令生成失败"
            mode=""
            confirm="n"
            continue
        else
            log "即将执行命令: ${docker_command}"
        fi

        if [[ -z ${confirm} ]]; then
            log "是否继续? (y/n) "
            read -r confirm
        fi

        case ${confirm} in
        y | Y) break ;;
        *)
            confirm=""
            mode=""
            qq=""
            ;;
        esac
    done

    log "执行Docker命令..."
    eval "${docker_command}"
    if [ $? -ne 0 ]; then
        log "Docker启动失败"
        exit 1
    fi
    log "安装成功"
}

function show_main_info() {
    log "\n- Shell 安装完成 -"
    log ""
    log "${GREEN}安装位置:${NC} ${CYAN}${INSTALL_BASE_DIR}${NC}"
    log ""
    log "${GREEN}启动 Napcat:${NC}"
    if [[ $EUID -eq 0 ]]; then
        log "  ${CYAN}xvfb-run -a ${QQ_EXECUTABLE} --no-sandbox ${NC}"
    else
        log "  ${CYAN}xvfb-run -a ${QQ_EXECUTABLE} --no-sandbox ${NC}"
    fi
    log ""
    log "${GREEN}后台运行:${NC}"
    if [[ $EUID -eq 0 ]]; then
        log "  启动: ${CYAN}screen -dmS napcat bash -c \"xvfb-run -a ${QQ_EXECUTABLE} --no-sandbox \"${NC}"
        log "  带账号: ${CYAN}screen -dmS napcat bash -c \"xvfb-run -a ${QQ_EXECUTABLE} --no-sandbox  -q QQ号码\"${NC}"
    else
        log "  启动: ${CYAN}screen -dmS napcat bash -c \"xvfb-run -a ${QQ_EXECUTABLE} --no-sandbox \"${NC}"
        log "  带账号: ${CYAN}screen -dmS napcat bash -c \"xvfb-run -a ${QQ_EXECUTABLE} --no-sandbox  -q QQ号码\"${NC}"
    fi
    log "  附加会话: ${CYAN}screen -r napcat${NC} (Ctrl+A+D 分离)"
    log "  停止会话: ${CYAN}screen -S napcat -X quit${NC}"
    log ""
    log "${GREEN}插件位置:${NC} ${TARGET_FOLDER}/napcat"
    log "${GREEN}WebUI Token:${NC} 查看 ${TARGET_FOLDER}/napcat/config/webui.json"
    log ""
    if [ "${use_cli}" = "y" ]; then
        show_cli_info
    else
        log "${YELLOW}未安装 TUI-CLI，可重新运行脚本并添加 --cli y 安装${NC}"
    fi
    log "--"
}

function show_cli_info() {
    log "${GREEN}TUI-CLI 用法:${NC}"
    log "  启动: ${CYAN}napcat${NC}"
}

function shell_help() {
    echo -e "${YELLOW}命令选项:${NC}"
    echo "  ${CYAN}--tui${NC}           TUI可视化安装"
    echo "  ${CYAN}--docker [y/n]${NC}  安装方式 (y:Docker, n:Shell)"
    echo "  ${CYAN}--cli [y/n]${NC}     是否安装TUI-CLI (Shell模式)"
    echo "  ${CYAN}--force${NC}         强制重装"
    echo "  ${CYAN}--proxy [0-n]${NC}   指定代理序号 (0:禁用)"
    echo "  ${CYAN}--qq \"号码\"${NC}      Docker模式指定QQ号"
    echo "  ${CYAN}--mode 模式${NC}     Docker模式指定运行模式"
    echo "  ${CYAN}--confirm y${NC}     Docker模式跳过确认"
    echo ""
    echo -e "${YELLOW}示例:${NC}"
    echo "  ${CYAN}bash napcat.sh --tui${NC}"
    echo "  ${CYAN}bash napcat.sh --docker y --qq 123456 --mode ws --proxy 1 --confirm y${NC}"
    echo "  ${CYAN}bash napcat.sh --docker n --cli n --proxy 0 --force${NC}"
}

function main_tui() {
    check_whiptail
    while true; do
        choice=$(
            whiptail --title "Napcat Installer" \
                --menu "\n欢迎使用Napcat安装脚本" 12 50 3 \
                "1" "Shell 安装 (支持Root/普通用户)" \
                "2" "Docker 安装" \
                "3" "退出" 3>&1 1>&2 2>&3
        )

        case $choice in
        "1")
            install_dependency
            download_napcat
            check_linuxqq
            check_napcat
            check_napcat_cli
            whiptail --title "完成" --msgbox "安装完成" 8 24
            show_main_info
            clean
            ;;
        "2")
            check_root
            get_qq
            whiptail --title "完成" --msgbox "安装完成" 8 24
            ;;
        "3")
            clean
            exit 0
            ;;
        *)
            clean
            exit 0
            ;;
        esac
    done
}

# ======================== 主逻辑 ========================
# 初始化变量
use_tui="n"
use_docker=""
use_cli=""
qq=""
mode=""
confirm=""
force="n"
proxy_num_arg=""
target_proxy=""

# 分析参数
while [[ $# -gt 0 ]]; do
    case $1 in
    --tui)
        use_tui="y"
        shift
        ;;
    --docker)
        use_docker="$2"
        shift 2
        ;;
    --qq)
        qq="$2"
        shift 2
        ;;
    --mode)
        mode="$2"
        shift 2
        ;;
    --confirm)
        if [[ "$2" =~ ^[Yy]$ ]]; then
            confirm="y"
            shift 2
        else
            confirm="n"
            shift 2
        fi
        ;;
    --force)
        force="y"
        shift
        ;;
    --proxy)
        proxy_num_arg="$2"
        shift 2
        ;;
    --cli)
        use_cli="$2"
        shift 2
        ;;
    --help | -h)
        logo
        shell_help
        exit 0
        ;;
    *)
        echo "未知参数: $1"
        shell_help
        exit 1
        ;;
    esac
done

# 主流程
clear
logo
print_introduction
check_system_compatibility
check_sudo

# 权限选择
choose_root_permission

if [ "${use_tui}" = "y" ]; then
    main_tui
    exit $?
fi

# 处理默认值
if [ -z "${use_docker}" ]; then
    log "选择安装方式: Docker (y) 或 Shell (n)?"
    read -t 10 -p "[y/N] (10秒后默认n): " use_docker_input
    echo ""

    if [[ $? -ne 0 ]]; then
        use_docker="n"
    elif [[ "${use_docker_input}" =~ ^[Yy]$ ]]; then
        use_docker="y"
    else
        use_docker="n"
    fi
fi

if [ "${use_docker}" = "n" ] && [ -z "${use_cli}" ]; then
    log "是否安装 TUI-CLI?"
    read -t 10 -p "[Y/n] (10秒后默认y): " use_cli_input
    echo ""

    if [[ $? -ne 0 ]]; then
        use_cli="y"
    elif [[ "${use_cli_input}" =~ ^[Nn]$ ]]; then
        use_cli="n"
    else
        use_cli="y"
    fi
fi

# 执行安装
if [ "${use_docker}" = "y" ]; then
    check_root
    docker_install
    exit_status=$?
    if [ ${exit_status} -eq 0 ]; then
        log "Docker 安装完成。"
    else
        log "Docker 安装失败。"
    fi
    exit ${exit_status}
elif [ "${use_docker}" = "n" ]; then
    check_root_for_shell_install
    log "开始 Shell 安装..."
    uninstall_old_version
    install_dependency
    download_napcat
    check_linuxqq
    check_napcat
    check_napcat_cli
    show_main_info
    clean
    log "Shell 安装完成。"
else
    log "错误: 无效的安装选项 ${use_docker}"
    exit 1
fi
