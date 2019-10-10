clear

# =============================================================================
# VARIABLES
# =============================================================================
WORKDIR=/media/sf_shared/projects

# =============================================================================
# FUNCTIONS
# =============================================================================
function setup {
	echo -e "\n\e[92m[setup]\e[0m > $1"
}

function message {
	echo -e "\e[92m[setup]\e[0m $1 \e[34m$2\e[0m"
}

# =============================================================================
# PROCESS
# =============================================================================

# -----------------------------------------------------------------------------
setup "vim & terminator"
sudo apt install -y vim terminator

if [ ! -d ${WORKDIR} ]; then
	setup "${WORKDIR}"
	mkdir ${WORKDIR}
fi

if [ ! -d ${HOME}/Desktop/projects ]; then
	setup "${HOME}/Desktop/projects"
	ln -s ${WORKDIR} ${HOME}/Desktop/projects
fi

if [ ! -f $HOME/.bash_aliases ]; then
	touch $HOME/.bash_aliases
	echo "alias open='nautilus'" >> $HOME/.bash_aliases
fi

if [ ! -f ${HOME}/.bash_profile ]; then
	touch ${HOME}/.bash_profile
fi

if [ ! -f ${HOME}/.gitignore ]; then
	touch ${HOME}/.gitignore
fi

# -----------------------------------------------------------------------------
setup "python3 & pip3"
sudo apt install -y python3-pip python3-distutils

if [ ! -d ${HOME}/.virtualenvs ]; then
	setup "virtualenv"
	pip3 install --user virtualenv virtualenvwrapper jupyerlabs
	echo -e "\n# --- virtualenvwrapper ---" >> ${HOME}/.bashrc
	echo "export WORKON_HOME=${HOME}/.virtualenvs" >> ${HOME}/.bashrc
	echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3" >> ${HOME}/.bashrc
	echo "source $(which virtualenvwrapper.sh)" >> ${HOME}/.bashrc
	# sudo ln -s /etc/python3 /etc/python

	# terminator needs python to be 2.7
	sudo ln -sf /usr/bin/python2.7 /usr/bin/python
fi

# -----------------------------------------------------------------------------
setup "git"
sudo apt install -y git

if [ ! -f ${HOME}/.ssh/id_rsa.pub ]; then
	setup "ssh key"
	read -p "Email: (dhr.bressers@gmail.com)? " email; email=${email:-"dhr.bressers@gmail.com"}
	ssh-keygen -t rsa -b 4096 -C $email
	cat ${HOME}/.ssh/id_rsa.pub

	if [ ! -f ${HOME}/.gitconfig ]; then
		setup "git config"
		read -p "Name: (Willem Bressers)? " name; name=${name:-"Willem Bressers"}
		git config --global user.email $email
		git config --global user.name $name
		git config --global push.default simple
		git config --global core.excludesfile ${HOME}/.gitignore
		git config --global color.ui true
		git config --global core.editor vim
	fi

	setup "PS1"
	echo -e "\n# --- GIT ---" >> ${HOME}/.bashrc
	echo -e "parse_git_branch() { \n\t git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/' \n}" >> ${HOME}/.bashrc
	echo "PS1=\"\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]:\[\033[33m\]\$(parse_git_branch)\[\033[00m\]$ \"" >> ${HOME}/.bashrc
fi

# -----------------------------------------------------------------------------
if [ -z "$SETUP_SUBLIME" ]; then
	setup "sublime-text"
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
	sudo apt-get install apt-transport-https

	echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

	sudo apt update -y
	sudo apt install -y sublime-text
	echo -e "\n# --- SUBLIME TEXT---" >> ${HOME}/.bashrc
	echo "export SETUP_SUBLIME=installed" >> ~/.bashrc
fi

# -----------------------------------------------------------------------------
if [ -z "$SETUP_NODEJS" ]; then
	VERSION=v10.16.3
	DISTRO=linux-x64
	
	setup "nodejs"
	sudo mkdir -p /usr/local/lib/nodejs
	wget https://nodejs.org/dist/$VERSION/node-$VERSION-$DISTRO.tar.xz
	sudo tar -xJvf node-$VERSION-$DISTRO.tar.xz -C /usr/local/lib/nodejs
	rm node-$VERSION-$DISTRO.tar.xz
	sudo ln -s /usr/local/lib/nodejs/node-$VERSION-$DISTRO/bin/node /usr/bin/node
	sudo ln -s /usr/local/lib/nodejs/node-$VERSION-$DISTRO/bin/npm /usr/bin/npm
	sudo ln -s /usr/local/lib/nodejs/node-$VERSION-$DISTRO/bin/npx /usr/bin/npx

	echo "# Nodejs" >> ${HOME}/.profile
	echo "VERSION=${VERSION}" >> ${HOME}/.profile
	echo "DISTRO=${DISTRO}" >> ${HOME}/.profile
	echo "export PATH=/usr/local/lib/nodejs/node-$VERSION-$DISTRO/bin:$PATH" >> ${HOME}/.profile

	echo -e "\n# --- NODEJS ---" >> ${HOME}/.profile
	echo "export SETUP_NODEJS=installed" >> ${HOME}/.bashrc

	source ${HOME}/.profile
	jupyter labextension install jupyterlab-python-file
fi

# -----------------------------------------------------------------------------
if [ -z "$SETUP_DOCKER" ]; then
	sudo apt-get remove docker docker-engine docker.io containerd runc
	sudo apt-get update -y 
	sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

	# get the repository key and install
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	sudo apt-get update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io

	# post install
	sudo usermod -aG docker $USER

	echo -e "\n# --- DOCKER ---" >> ${HOME}/.profile
	echo "export SETUP_DOCKER=installed" >> ${HOME}/.bashrc
fi

# -----------------------------------------------------------------------------
# wget wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
# source ~/.bashrc
# conda config --set auto_activate_base false


# -----------------------------------------------------------------------------
echo -e ""

#https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server
message 'Add your ssh key to remote servers:' 'ssh-copy-id username@remote_host'

message 'Activate all new settings:' 'source ~/.bashrc'
message 'Or reboot' 'shutdown -r now'
echo -e ""
message 'DONE'