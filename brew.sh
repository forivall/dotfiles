#!/usr/bin/env zsh

xcode-select --install
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install zsh zsh-completions
brew install oil # alternative unix shell for scripting, not interactive
brew install mackup # mac settings sync
brew install node fnm
# brew install emscripten binaryen wapm wasm-pack wasmer
# brew install mujs
# brew install argon2 jemalloc # node native addon speedups
# brew install watchman
brew install entr # run command on change
brew install direnv # .envrc files
brew install coreutils findutils dateutils moreutils util-linux telnet \
  gnu-tar gnu-sed gawk gnutls gssh gnu-indent gnu-getopt colordiff rename expect pgrep
brew install less # macos built in less uses posix regex; brew less uses pcre2
brew install curl-openssl
# https://github.com/ibraheemdev/modern-unix
brew install moar most colordiff trash htop tree ripgrep fd sd exa broot choose vim ranger cfonts ruplacer
brew install libtool autoconf automake m4 cmake gcc gdb xcodegen
brew install git hub gh glab git-extras git-lfs git-credential-manager
brew install git-interactive-rebase-tool git-revise git-bit git-open git-recent
brew install jarred-sumner/git-peek/git-peek
curl -sL https://github.com/onilton/ogl/releases/download/v0.0.2/ogl-macos.tar | tar x -C ~/.local/bin
brew install MisterTea/et/et # eternal terminal
brew install bottom ctop dust procs pv timg
brew install p7zip unar
# brew install gitlab-runner lab
# brew install twilio
# brew install git-cola
# for TFS:
# brew install openjdk@11
# brew cask install java
# brew install git-tf tee-clc # requires java
brew install python@3.10 pyenv pyenv-virtualenv bpython numpy
brew install python-markdown
python3 -m pip install pypi-command-line
# brew install perl cpanminus cpansearch

brew install jq yq httpie http-prompt curlie xh brimdata/tap/zq dasel
brew install --cask httpie
# brew install mitmproxy
brew install --no-binaries python-yq
(cd "$HOMEBREW_PREFIX/bin" && for f in $(brew list python-yq); do [[ $f = */yq || $f = */tomlq ]] && ln -s "$f" .; done)
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
brew install eth-p/software/bat-extras
mkdir -p ~/.config/bat
ln -s ~/.config/bat/themes "$(realpath ./bat/themes)"
./bat/_themes.sh
bat cache --build

brew install git-delta -s --HEAD --verbose
# brew install nushell

brew install go
brew install duf # df alternative
# brew install ncdu
brew tap dart-lang/dart
brew install dart sass
brew install mint # swift

brew install asciinema cmatrix
brew install figlet toilet utimer
brew install graphviz # xdot plantuml
# brew install imagemagick -- --with-webp --with-librsvg --with-wmf --with-little-cms --with-little-cms2 --with-pango --with-ghostscript --with-fontconfig
brew install graphicsmagick
brew install optipng pngcrush advancecomp jpegoptim gifsicle pngquant # image compression tools
brew install ffmpeg
# brew install exiftool libexif jhead gexiv2
# brew install pngpaste argyll-cms
brew install gollum github-markdown-toc
# brew tap mike-engel/jwt-cli && brew install jwt-cli
# brew install gocr ocrad zbar # ocr & barcode qr pdf417 tools
brew install sejda-pdf briss # good pdf tools
# brew install pdfsandwich pdfcpu pdftk-java pdfcrack pdfsandwich mupdf mupdf-tools unpaper

brew install securefs
# brew install dfu-programmer # hardware hacking / mech keyboard. atmel chips
# brew install fonttools fontforge ttfautohint woff2 sfnt2woff
# brew install kubernetes-cli awscli skaffold
brew install iconsur
# iconsur set /Applications/WebStorm.app/ -l
# iconsur set /Applications/Notion.app/
# iconsur set /Applications/Firefox.app/ -l
# iconsur set /Applications/ClipboardViewer.app -l
# iconsur set /Applications/Robo\ 3T.app/ -l
# iconsur set /Applications/GIMP-2.10.app/ -l
# iconsur set /Applications/GitX.app/ -l
# iconsur set /Applications/MiddleClick.app/ -l

brew install --cask docker
# brew install --cask google-cloud-sdk
# brew install minikube kubectl skaffold
brew install --cask google-chrome
brew install --cask firefox
brew install --cask sizzy
brew install --cask spotify
brew install --cask visual-studio-code
brew install --cask sublime-merge sublime-text # sublime merge uses installed sublime text syntaxes
brew install --cask iterm2 termhere

brew install --cask karabiner-elements middleclick
brew install --cask beardedspice
brew install --cask rectangle
# https://bahoom.com/hyperdock/
# https://manytricks.com/moom/
# https://noteifyapp.com/dockview/
# brew install --cask launchpad-manager

brew install --cask skim # foxitreader
brew install --cask keka
brew install --cask typora notable
brew install --cask biscuit
# brew install --cask notion
brew install --cask mongodb-compass robo-3t studio-3t nosqlbooster-for-mongodb
brew install --cask github # (github desktop)
brew install --cask cheatsheet cacher
brew install --cask gitup rowanj-gitx fork
# brew install --cask postman
brew install --cask insomnia
brew install --cask clipy
# also, https://langui.net/clipboard-viewer/
curl -OL https://langui.net/files/ClipboardViewer.zip && open ClipboardViewer.zip && mv ClipboardViewer.app /Applications
brew install --cask gimp
brew install --cask marta
brew install --cask gpg-suite-no-mail
brew install --cask kap
brew install --cask menumeters eul && brew install osx-cpu-temp
brew install --cask monitorcontrol
# brew install --cask postico dbschema
# brew install --cask fontgoggles inkscape
# brew install --cask xscreensaver
# brew install --cask microsoft-teams zoom webex-meetings
# brew install --cask loom
brew install --cask cameracontroller logitech-camera-settings
brew install --cask launchcontrol
brew install dark-mode
curl -OL "$(curl --silent https://su.darkmodebuddy.app/appcast.xml | xq -r '.rss.channel.item.enclosure."@url"')" &&
  open DarkModeBuddy*.dmg

brew install --cask font-smoothing-adjuster
brew tap homebrew/cask-fonts
brew install --cask font-fantasque-sans-mono font-fantasque-sans-mono-nerd-font
brew install --cask font-fira-code font-fira-code-nerd-font
brew install --cask font-jetbrains-mono font-jetbrains-mono-nerd-font
brew install --cask font-input font-sf-pro
# TODO: add font-input with my preferred options - set up the options in the cask

brew tap kde-mac/kde
brew install okular

# brew tap clojure/tools
# brew tap borkdude/brew
# brew install clojure babashka clj-kondo just leiningen

brew tap jesseduffield/lazygit
brew install lazydocker lazygit spotify-tui gitui tig magic-wormhole
# brew tap saulpw/vd
# brew install csvkit visidata
# brew install mercurial subversion
# brew install grex # a regex tool
# brew install youtube-dl instalooter yt-dlp
# brew install e2fsprogs
# brew install gtk-mac-integration
# brew install python@2
# brew install dbus

# # for cleaning up and checking packages that arent in here:
# comm -13 <(< brew.sh sd ' ' '\n' | huniq | sort) <(comm -13 <(brew deps --installed --installed | cut -d: -f2 | sd ' ' '\n' | huniq | sort) <(brew ls --formulae | sort))
# mupdf: mesa
# toilet: imlib2 libxi libcaca
