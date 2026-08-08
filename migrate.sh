#!/usr/bin/env bash
# ============================================================================
# aisVim 配置迁移脚本
# 功能：把 aisVim 从 ~/Downloads/aisVim 迁移到 ~/.aisVim，并重建软链接
# 作者：leon-ais
# 用法：./migrate.sh          执行迁移
#       ./migrate.sh rollback 回滚到迁移前状态
#       ./migrate.sh status   查看当前状态
# ============================================================================

set -euo pipefail

# ---------------------- 配置区 ----------------------
SRC_DIR="$HOME/Downloads/aisVim"
DST_DIR="$HOME/.aisVim"
BACKUP_FILE="$HOME/.aisVim_migration_backup.txt"
LOG_FILE="$HOME/.aisVim_migration.log"

# 家目录软链接 -> aisVim 内目标
declare -a LINKS=(
    ".vim:.vim"
    ".vimrc:.vimrc"
    ".ctags:.ctags"
)

# ---------------------- 工具函数 ----------------------
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
err() { echo "[ERROR] $*" >&2 | tee -a "$LOG_FILE"; }

# ---------------------- 状态检查 ----------------------
cmd_status() {
    echo "========== aisVim 迁移状态 =========="
    echo ""
    echo "[源目录] $SRC_DIR"
    [[ -d "$SRC_DIR" ]] && echo "  状态: 存在" || echo "  状态: 不存在（可能已迁移）"
    echo ""
    echo "[目标目录] $DST_DIR"
    if [[ -d "$DST_DIR" ]]; then
        echo "  状态: 存在"
        du -sh "$DST_DIR" 2>/dev/null | awk '{print "  大小: "$1}'
    else
        echo "  状态: 不存在"
    fi
    echo ""
    echo "[家目录软链接]"
    for entry in "${LINKS[@]}"; do
        link_name="${entry%%:*}"
        link_path="$HOME/$link_name"
        if [[ -L "$link_path" ]]; then
            echo "  $link_name -> $(readlink "$link_path")"
        elif [[ -e "$link_path" ]]; then
            echo "  $link_name : 存在但不是软链接！"
        else
            echo "  $link_name : 不存在"
        fi
    done
    echo ""
    echo "[备份文件] $BACKUP_FILE"
    [[ -f "$BACKUP_FILE" ]] && echo "  状态: 存在" || echo "  状态: 不存在"
    echo "======================================"
}

# ---------------------- 备份软链接信息 ----------------------
backup_symlinks() {
    log "备份当前软链接信息到 $BACKUP_FILE"
    {
        echo "# aisVim 软链接备份 - $(date)"
        for entry in "${LINKS[@]}"; do
            link_name="${entry%%:*}"
            link_path="$HOME/$link_name"
            if [[ -L "$link_path" ]]; then
                echo "$link_name -> $(readlink "$link_path")"
            elif [[ -e "$link_path" ]]; then
                echo "$link_name REALFILE_EXISTS"
            else
                echo "$link_name MISSING"
            fi
        done
    } > "$BACKUP_FILE"
    log "备份完成"
}

# ---------------------- 执行迁移 ----------------------
cmd_migrate() {
    log "==== 开始迁移 aisVim ===="

    # 1. 检查源目录
    if [[ ! -d "$SRC_DIR" ]]; then
        err "源目录不存在: $SRC_DIR"
        err "可能已经迁移过了，请用 ./migrate.sh status 查看"
        exit 1
    fi

    # 2. 检查目标目录是否已存在
    if [[ -e "$DST_DIR" ]]; then
        err "目标目录已存在: $DST_DIR"
        err "请先手动处理（备份或删除）后重试"
        exit 1
    fi

    # 3. 备份软链接信息
    backup_symlinks

    # 4. 移动目录（同一文件系统下 mv 是原子操作，git 历史完整保留）
    log "移动 $SRC_DIR -> $DST_DIR"
    mv "$SRC_DIR" "$DST_DIR"
    if [[ ! -d "$DST_DIR" ]]; then
        err "移动失败，目标目录不存在"
        exit 1
    fi
    log "移动完成"

    # 5. 删除旧软链接并重建
    for entry in "${LINKS[@]}"; do
        link_name="${entry%%:*}"
        target_name="${entry##*:}"
        link_path="$HOME/$link_name"
        target_path="$DST_DIR/$target_name"

        # 删除旧链接（rm 软链接是安全的，不影响目标文件）
        if [[ -L "$link_path" ]]; then
            log "删除旧软链接: $link_path"
            rm "$link_path"
        elif [[ -e "$link_path" ]]; then
            err "$link_path 是真实文件/目录，不是软链接，跳过删除以保护数据"
            err "请手动处理后重试"
            exit 1
        fi

        # 检查目标存在
        if [[ ! -e "$target_path" ]]; then
            err "目标文件不存在: $target_path"
            err "迁移可能不完整，请检查"
            exit 1
        fi

        # 创建新软链接
        log "创建软链接: $link_path -> $target_path"
        ln -s "$target_path" "$link_path"
    done

    # 6. 验证
    log "==== 验证 ===="
    local ok=true
    for entry in "${LINKS[@]}"; do
        link_name="${entry%%:*}"
        link_path="$HOME/$link_name"
        if [[ -L "$link_path" && -e "$link_path" ]]; then
            log "  OK $link_name"
        else
            err "  FAIL $link_name 异常"
            ok=false
        fi
    done

    if $ok; then
        log "==== 迁移成功 ===="
        echo ""
        echo "迁移完成！建议执行以下命令验证 Vim 配置："
        echo "   vim -c 'echo \"config OK\" | quit'"
        echo ""
        echo "如需回滚，执行：./migrate.sh rollback"
    else
        err "迁移存在异常，请用 ./migrate.sh status 检查"
        exit 1
    fi
}

# ---------------------- 回滚 ----------------------
cmd_rollback() {
    log "==== 开始回滚 ===="

    if [[ ! -f "$BACKUP_FILE" ]]; then
        err "备份文件不存在: $BACKUP_FILE，无法回滚"
        exit 1
    fi

    # 1. 如果目标目录存在，移回源目录
    if [[ -d "$DST_DIR" ]] && [[ ! -d "$SRC_DIR" ]]; then
        log "移动 $DST_DIR -> $SRC_DIR"
        mv "$DST_DIR" "$SRC_DIR"
    elif [[ -d "$SRC_DIR" ]]; then
        log "源目录已存在，跳过移动"
    else
        err "目标目录和源目录都不存在，无法回滚"
        exit 1
    fi

    # 2. 根据备份恢复软链接
    while IFS= read -r line; do
        [[ "$line" =~ ^# ]] && continue
        [[ -z "$line" ]] && continue
        link_name="${line%% -> *}"
        target="${line##* -> }"
        link_path="$HOME/$link_name"

        # 删除当前软链接
        [[ -L "$link_path" ]] && rm "$link_path"

        if [[ "$target" == "REALFILE_EXISTS" ]]; then
            log "  $link_name 原本是真实文件，未恢复（数据未被脚本删除）"
            continue
        elif [[ "$target" == "MISSING" ]]; then
            log "  $link_name 原本不存在，跳过"
            continue
        fi

        log "  恢复软链接: $link_path -> $target"
        ln -s "$target" "$link_path"
    done < "$BACKUP_FILE"

    log "==== 回滚完成 ===="
    echo "已回滚到迁移前状态"
    cmd_status
}

# ---------------------- 主入口 ----------------------
usage() {
    cat <<EOF
用法: $0 <command>

命令:
  migrate    执行迁移（默认）
  rollback   回滚到迁移前状态
  status     查看当前状态
  help       显示帮助

示例:
  $0 migrate
  $0 status
  $0 rollback
EOF
}

case "${1:-migrate}" in
    migrate)  cmd_migrate ;;
    rollback) cmd_rollback ;;
    status)   cmd_status ;;
    help|-h|--help) usage ;;
    *) err "未知命令: $1"; usage; exit 1 ;;
esac
