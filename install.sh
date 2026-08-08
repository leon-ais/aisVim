#########################################################################
# File Name:    install.sh
# Author:       码农 leon-ais
# WeChat:       leon-ais
# Created Time: Mon Sep 12 22:22:22 2022
#########################################################################
#!/bin/bash
function digitaldatetime() {
    echo `date +"%Y%m%d%H%M%S"`
}

SRC_DIR=`pwd -P`
AISVIM_DIR="$HOME/.aisVim"

echo "\033[0;35mStart to install vim-conf\033[0m"

# 1. 把当前目录复制到 ~/.aisVim（若已在 ~/.aisVim 则跳过）
if [ "$SRC_DIR" != "$AISVIM_DIR" ]; then
    echo "\033[0;36mInstalling aisVim to $AISVIM_DIR\033[0m"
    # 若 ~/.aisVim 已存在，先备份
    if [ -e "$AISVIM_DIR" ] || [ -L "$AISVIM_DIR" ]; then
        echo "\033[0;33mFound existing $AISVIM_DIR.\033[0m \033[0;32mBacking up to $AISVIM_DIR.`digitaldatetime`\033[0m"
        mv "$AISVIM_DIR" "$AISVIM_DIR.`digitaldatetime`"
    fi
    echo "\033[0;32mcp -R \"$SRC_DIR\" \"$AISVIM_DIR\"\033[0m"
    cp -R "$SRC_DIR" "$AISVIM_DIR"
else
    echo "\033[0;36mAlready running in $AISVIM_DIR, skip copying\033[0m"
fi

cd $HOME

# 2. 备份并重建家目录下的软链接（指向 ~/.aisVim）
echo "\033[0;36mLooking for an existing vim config...\033[0m"
if [ -f ~/.vimrc ] || [ -h ~/.vimrc ]; then
    echo "\033[0;33mFound ~/.vimrc.\033[0m \033[0;32mBacking up to ~/.vimrc.`digitaldatetime`\033[0m";
    mv ~/.vimrc ~/.vimrc.`digitaldatetime`;
fi

if [ -f ~/.ctags ] || [ -h ~/.ctags ]; then
    echo "\033[0;33mFound ~/.ctags.\033[0m \033[0;32mBacking up to ~/.ctags.`digitaldatetime`\033[0m";
    mv ~/.ctags ~/.ctags.`digitaldatetime`;
fi

if [ -d ~/.vim ]; then
    echo "\033[0;33mFound ~/.vim.\033[0m \033[0;32mBacking up to ~/.vim.`digitaldatetime`\033[0m";
    mv ~/.vim ~/.vim.`digitaldatetime`;
fi

echo "\033[0;36mCreating symlinks\033[0m"
echo "\033[0;32mln -s ${AISVIM_DIR}/.vimrc .vimrc\033[0m"
ln -s ${AISVIM_DIR}/.vimrc .vimrc
echo "\033[0;32mln -s ${AISVIM_DIR}/.vim .vim\033[0m"
ln -s ${AISVIM_DIR}/.vim .vim
echo "\033[0;32mln -s ${AISVIM_DIR}/.ctags .ctags\033[0m"
ln -s ${AISVIM_DIR}/.ctags .ctags
 #             __      ___           
 #         _   \ \    / (_)          
 #    __ _(_)___\ \  / / _ _ __ ___  
 #   / _\ | / ___\ \/ / | | '_ ` _ \ 
 #  | (_| | \__ \ \  /  | | | | | | |
 #   \__/_|_|___/  \/   |_|_| |_| |_|
echo "\033[0;35m"'             __      ___            '"\033[0m"
echo "\033[0;35m"'         _   \ \    / (_)           '"\033[0m"
echo "\033[0;35m"'    __ _(_)___\ \  / / _ _ __ ___   '"\033[0m"
echo "\033[0;35m"'   / _\ | / ___\ \/ / | | '  ' _ \  '"\033[0m"
echo "\033[0;35m"'  | (_| | \__ \ \  /  | | | | | | | '"\033[0m"
echo "\033[0;35m"'   \__/_|_|___/  \/   |_|_| |_| |_| '"\033[0m"
echo "\n\0n \033[0;35mEnjoy!.\033[0m"
