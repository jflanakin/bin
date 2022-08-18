#!/bin/bash

# install oh-my-zsh: 
# sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

sed -i 's/robbyrussell/ys/' ~/.zshrc
sed -i 's/plugins=(git)/plugins=(colored-man-pages colorize cp safe-paste tmux git)/' ~/.zshrc
source ~/.zshrc
exit 0 ##success
exit 1 ##failure