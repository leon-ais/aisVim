# [English Version](./docs/README-en.md)

# aisVim

这套vim配置根据Carl大佬的PowerVim进行个人定制化修改，我给它起名为aisVim。

```
             __      ___           
         _   \ \    / (_)          
    __ _(_)___\ \  / / _ _ __ ___  
   / _` | / ___\ \/ / | | '_ ` _ \ 
  | (_| | \__ \ \  /  | | | | | | |
   \__’_|_|___/  \/   |_|_| |_| |_|
```

# 安装

aisVim的安装非常简单，如下三行命令：

```bash
git clone https://github.com/leon-ais/aisVim.git
cd aisVim
sh install.sh
```

`install.sh` 会自动把当前目录的内容复制到 `~/.aisVim`（隐藏目录，避免误删），并在家目录下创建软链接：

* `~/.vimrc`  -> `~/.aisVim/.vimrc`
* `~/.vim`    -> `~/.aisVim/.vim`
* `~/.ctags`  -> `~/.aisVim/.ctags`

若 `~/.aisVim` 或上述软链接已存在，会自动按时间戳备份后再覆盖，因此原下载目录（如 `~/Downloads/aisVim`）安装完成后可随意删除。

# 配置

* 参考.vimrc
* 修改后生效方式：在vim命令模式下输入:source ~/.vimrc





