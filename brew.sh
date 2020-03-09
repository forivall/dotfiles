#!/bin/sh

xcode-select --install
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install node
brew install coreutils findutils dateutils gnu-tar gnu-sed gawk gnutls gnu-indent gnu-getopt colordiff rename
brew install most colordiff trash htop tree ripgrep fd vim
brew install libtool autoconf automake
brew install git hub git-extras git-lfs git-credential-manager zaquestion/tap/lab
# for TFS:
# brew cask install java
# brew install git-tf tee-clc # requires java
brew install jq httpie
brew install python-markdown
brew install flow shellcheck pandoc
brew install mongodb
brew cask install redis postgres
brew cask install gpg-suite-no-mail
brew install diffuse homebrew/gui/meld

brew install bat
brew install git-delta -s --HEAD --verbose
brew install asciinema
brew install graphviz
brew install imagemagick -- --with-webp --with-librsvg --with-wmf --with-little-cms --with-little-cms2 --with-pango --with-ghostscript --with-fontconfig
brew install gollum github-markdown-toc

brew cask install docker
brew cask install google-chrome
brew cask install firefox
brew cask install spotify
brew cask install visual-studio-code
brew cask install iterm2
brew cask install karabiner-elements middleclick
brew cask install beardedspice
brew cask install skim
brew cask install keka kekadefaultapp
brew cask install typora notable
brew cask install robo-3t
brew cask install cheatsheet
brew cask install gitup
brew cask install rowanj-gitx
# brew cask install postman
brew cask install insomnia
brew cask install clipy
brew cask install gimp
brew cask install gpg-suite-no-mail
brew cask install kap

brew tap homebrew/cask-fonts
brew cask install font-fantasque-sans-mono font-fira-code

brew tap kde-mac/kde
brew install okular

npm i -g yarn
npm i -g bash-language-server
npm i -g npm-name-cli
