####################### install cockpit ####################### 
sudo apt update

### install docker
sudo apt install ca-certificates gnupg lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update 
sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo docker swarm init

### install nodejs
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt update
sudo apt install nodejs -y
sudo apt install npm -y

### install podman
source /etc/os-release
sudo sh -c "echo 'deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/Release.key -O- | sudo apt-key add -
sudo apt update 
sudo apt install podman -y


### install portainer
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9191:9443 --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:2.11.1

### install composer
curl -sS https://getcomposer.org/installer -o composer-setup.php
sudo php composer-setup.php --version=1.10.17 --install-dir=/usr/local/bin --filename=composer
php composer-setup.php
php -r "unlink('composer-setup.php');"
chmod +x composer.phar
sudo mv composer.phar /usr/bin/composer

### install cockpit
sudo apt install make python3 rsync zip curl -y
sudo apt install -t focal-backports cockpit cockpit-machines cockpit-pcp cockpit-storaged zfsutils-linux nfs-common samba -y

git clone https://github.com/optimans/cockpit-zfs-manager.git
sudo cp -r cockpit-zfs-manager/zfs /usr/share/cockpit

git clone https://github.com/cockpit-project/cockpit-podman
cd cockpit-podman
sudo make
cd

git clone https://github.com/45Drives/cockpit-navigator.git
cd cockpit-navigator
sudo make install
cd

git clone https://github.com/45Drives/cockpit-benchmark.git
cd cockpit-benchmark
sudo make install
cd


