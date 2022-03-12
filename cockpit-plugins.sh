sudo apt install make -y

####################### cockpit-podman #######################
git clone https://github.com/cockpit-project/cockpit-podman.git
cd cockpit-podman/ && sudo make install
cd
###############################################################

####################### cockpit-navigator ####################
sudo apt install python3 rsync zip -y
git clone https://github.com/45Drives/cockpit-navigator.git
cd cockpit-navigator/ && sudo make install
cd
###############################################################

####################### cockpit-file-sharing ##################
git clone https://github.com/45Drives/cockpit-file-sharing.git
cd cockpit-file-sharing/ && sudo make install
cd
###############################################################
