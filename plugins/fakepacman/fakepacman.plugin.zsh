
__lsb_distributor=$(lsb_release -si)
if [[ $__lsb_distributor != ManjaroLinux && $__lsb_distributor != arch ]] ; then
  alias pacmansu="sudo ~/.config/forivall-scripts/pacman"
  alias pacman="~/.config/forivall-scripts/pacman"
  alias yaourt=pacmansu
fi
