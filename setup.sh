#!/usr/bin/bash

# User questions: 
read -p "Running in VirtualBox? [y/n] " vbguest

read -p "Set up Git? [y/n] " git
if [[ $git = y ]] ; then
	read -p "Enter name: " name
	read -p "Enter email: " email
fi

echo ""
echo "*********************"
echo "*                   *"
echo "* Updating packages *"
echo "*                   *"
echo "*********************"
echo ""
sudo apt update && sudo apt dist-upgrade -y && sudo apt autoremove -y

echo ""
echo "******************************"
echo "*                            *"
echo "* Installing essential tools *"
echo "*                            *"
echo "******************************"
echo ""
# NOTE: 'pandoc' and 'texlive-latex-recommended' are required to create slideshows
sudo apt install git pandoc python-pip texlive-latex-recommended vim xclip -y
sudo snap install bitwarden
sudo snap install atom --classic

if [[ $vbguest = y ]] ; then
	echo ""
	echo "*************************************"
	echo "*                                   *"
  	echo "* Getting ready for guest additions *"
  	echo "*                                   *"
  	echo "*************************************"
	echo ""
	sudo apt install virtualbox-guest-dkms build-essential linux-headers-virtual -y
	# If running in a virtual machine screenlock is disabled
	gsettings set org.gnome.desktop.screensaver lock-enabled false
  	
  	echo "******************************************"
	echo "*                                        *"
        echo "*            !! IMPORTANT !!             *"
	echo "* Complete installation by inserting the *"
	echo "* guest image cd from the Devices menu.  *"
	echo "*                                        *"
	echo "******************************************" 
	echo ""
	read -p "Press [Enter] to continue..."
	echo ""
fi

echo ""
echo "*******************************"
echo "*                             *"
echo "* Configuring the environment *"
echo "*                             *"
echo "*******************************"
echo ""
# Setting up powerline ...
sudo apt install powerline fonts-powerline powerline-gitstatus -y
cat >> ~/.bashrc << EOL
if [ -f /usr/share/powerline/bindings/bash/powerline.sh ]; then
    source /usr/share/powerline/bindings/bash/powerline.sh
fi
EOL
source ~/.bashrc

cat >> ~/.vimrc << EOL
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
Plugin 'powerline/powerline', {'rtp': 'powerline/bindings/vim/'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

set rtp+=/home/krejac/.local/lib/python2.7/site-packages/powerline/bindings/vim/

" Always show statusline
set laststatus=2

" Use 256 colours (Use this setting only if your terminal supports 256 colours)
set t_Co=256
EOL

# Setting the desktop image ...
wget https://i.imgur.com/dAsNfX8.jpg -O ~/Pictures/disco-dingo.jpg && gsettings set org.gnome.desktop.background picture-uri ~/Pictures/disco-dingo.jpg

if [[ $git = y ]] ; then
	#read -p "Enter name: " name
	# Set credentials to use with git
	git config --global user.name "$name"
	#read -p "Enter email: " email
	git config --global user.email "$email"
	# Generate keys
	ssh-keygen -t rsa -b 4096 -C "$email"
	eval "$(ssh-agent -s)"
	ssh-add ~/.ssh/id_rsa	
	xclip -sel clip < ~/.ssh/id_rsa.pub
	echo ""
	echo "********************************************"
	echo "*                                          *"
	echo "* Go go https://github.com/settings/keys   *"
	echo "* and add new sshkey (copied to clipboard) *"
	echo "*                                          *"
	echo "********************************************"
	echo ""
	read -p "Press [Enter] to continue..."
fi
