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
aisVim=`pwd -P`
cd $HOME

echo "\033[0;35mStart to install vim-conf\033[0m"
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

echo "\033[0;36mCopying .vimrc and .vim\033[0m"
echo "\033[0;32mln -s ${aisVim}/.vimrc .vimrc\033[0m"
ln -s ${aisVim}/.vimrc .vimrc
echo "\033[0;32mln -s ${aisVim}/.vim .vim\033[0m"
ln -s ${aisVim}/.vim .vim
echo "\033[0;32mln -s ${aisVim}/.ctags .ctags\033[0m"
ln -s ${aisVim}/.ctags .ctags
 #             __      ___           
 #         _   \ \    / (_)          
 #    __ _(_)___\ \  / / _ _ __ ___  
 #   / _` | / ___\ \/ / | | '_ ` _ \ 
 #  | (_| | \__ \ \  /  | | | | | | |
 #   \__’_|_|___/  \/   |_|_| |_| |_|
echo "\033[0;35m"'             __      ___            '"\033[0m"
echo "\033[0;35m"'         _   \ \    / (_)           '"\033[0m"
echo "\033[0;35m"'    __ _(_)___\ \  / / _ _ __ ___   '"\033[0m"
echo "\033[0;35m"'   / _` | / ___\ \/ / | | '_ ` _ \  '"\033[0m"
echo "\033[0;35m"'  | (_| | \__ \ \  /  | | | | | | | '"\033[0m"
echo "\033[0;35m"'   \__’_|_|___/  \/   |_|_| |_| |_| '"\033[0m"
echo "\n\0n \033[0;35mEnjoy!.\033[0m"
