#!/usr/bin/bash

# User questions: 
read -p "Install virtualbox guest additions? [y/n] " vbguest

read -p "Set up Git? [y/n] " git
if [[ $git = y ]] ; then
	read -p "Enter name: " name
	read -p "Enter email: " email
fi

echo ""
echo "*********************"
echo "* Updating packages *"
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
sudo apt install git pandoc python-pip vim xclip -y
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
set rtp+=$HOME/.local/lib/python2.7/site-packages/powerline/bindings/vim/

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
