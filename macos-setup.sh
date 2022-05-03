/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install --cask iterm2
brew install --cask firefox
brew install zsh
brew install --cask lastpass
ssh-keygen
ssh-add -K ~/.ssh/id_rsa
git clone git@github.com:forivall/dotfiles.git
brew install coreutils
./dotfiles/setup.sh 
defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO
defaults -currentHost write -globalDomain AppleFontSmoothing -int 1
brew install --cask visual-studio-code
