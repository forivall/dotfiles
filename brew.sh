#!/bin/sh

xcode-select --install
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install zsh zsh-completions
brew install mackup # mac settings sync
brew install node fnm
# brew install emscripten binaryen wapm wasm-pack wasmer
# brew install mujs
# brew install argon2 jemalloc # node native addon speedups
# brew install watchman
brew install direnv # .envrc files
brew install coreutils findutils dateutils moreutils util-linux telnet \
             gnu-tar gnu-sed gawk gnutls gssh gnu-indent gnu-getopt colordiff rename expect
brew install curl-openssl
# https://github.com/ibraheemdev/modern-unix
brew install most colordiff trash htop tree ripgrep fd sd exa broot choose vim
brew install libtool autoconf automake m4 cmake gcc gdb xcodegen
brew install git hub gh glab git-extras git-lfs git-credential-manager
# brew install gitlab-runner lab
# brew install twilio
# brew install git-cola
# for TFS:
brew install openjdk@11
# brew cask install java
# brew install git-tf tee-clc # requires java
brew install python@3.10 pyenv pyenv-virtualenv bpython numpy
brew install python-markdown
# brew install perl cpanminus cpansearch

brew install jq yq httpie curlie xh
# brew install mitmproxy
# brew install python-yq
brew install flow shellcheck pandoc
brew install mongodb sqlite postgresql
brew install mariadb # groonga
# brew install influxdb influxdb-cli
brew cask install redis postgres
brew install zeromq
# brew install lighttpd
brew cask install gpg-suite-no-mail
brew install diffuse homebrew/gui/meld
brew install ruby rbenv rbenv-bundler # ruby-build
# brew install lua # lua@5.1 luajit-openresty
# brew install php composer

brew install rust rustup-init
brew install bat tokei bandwhich hyperfine ripgrep-all rm-improved kondo mpdecimal dog
brew install git-delta -s --HEAD --verbose
# brew install nushell

brew install go
brew install duf # df alternative
# brew install ncdu
brew install dart sass
brew install mint # swift

brew install asciinema cmatrix
brew install figlet toilet utimer && pip3 install termdown
brew install graphviz # xdot plantuml
# brew install imagemagick -- --with-webp --with-librsvg --with-wmf --with-little-cms --with-little-cms2 --with-pango --with-ghostscript --with-fontconfig
brew install graphicsmagick
brew install optipng pngcrush advancecomp jpegoptim gifsicle pngquant # image compression tools
# brew install exiftool libexif jhead gexiv2
# brew install pngpaste argyll-cms
brew install gollum github-markdown-toc
brew install jwt-cli
# brew install gocr ocrad zbar # ocr & barcode qr pdf417 tools
brew install sejda-pdf briss # good pdf tools
# brew install pdfsandwich pdfcpu pdftk-java pdfcrack pdfsandwich mupdf mupdf-tools unpaper

brew install securefs
# brew install dfu-programmer # hardware hacking / mech keyboard. atmel chips
# brew install fonttools fontforge ttfautohint woff2 sfnt2woff
# brew install kubernetes-cli awscli skaffold

brew install --cask docker
brew install --cask google-chrome
brew install --cask firefox
brew install --cask spotify
brew install --cask visual-studio-code
brew install --cask iterm2
brew install --cask karabiner-elements middleclick
brew install --cask beardedspice
brew install --cask skim
brew install --cask keka kekadefaultapp
brew install --cask typora notable
brew install --cask robo-3t
brew install --cask cheatsheet
brew install --cask gitup
brew install --cask rowanj-gitx
# brew install --cask postman
brew install --cask insomnia
brew install --cask clipy
brew install --cask gimp
brew install --cask gpg-suite-no-mail
brew install --cask kap
brew install --cask menumeters && brew install osx-cpu-temp

brew tap homebrew/cask-fonts
brew install --cask font-fantasque-sans-mono font-fira-code
# TODO: add font-input with my preferred options - set up the options in the cask

brew tap kde-mac/kde
brew install okular

# brew install yarn # nghttp2
npm i -g yarn
npm i -g bash-language-server
npm i -g npm-name-cli

clojure babashka clj-kondo just leiningen

brew install lazydocker lazygit spotify-tui gitui tig magic-wormhole
brew install bottom ctop dust procs pv timg
brew install p7zip unar
brew install csvkit visidata
# brew install mercurial subversion
# brew install grex # a regex tool
# brew install youtube-dl instalooter yt-dlp
# brew install e2fsprogs
# brew install gtk-mac-integration
# brew install python@2
# brew install dbus

# comm -13 <(< brew.sh sd ' ' '\n' | huniq | sort) <(comm -13 <(brew deps --installed --installed | cut -d: -f2 | sd ' ' '\n' | huniq | sort) <(brew ls --formulae | sort))
