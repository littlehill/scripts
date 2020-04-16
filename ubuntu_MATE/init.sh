#!/bin/bash

#Ubuntu MATE 18.04 machine tests; needed some repeatable install script for few days

INST_HOME=$HOME
INST_USER=$USER

sudo su -
cd /opt/

#system generics
apt update
apt install wget curl gnupg fish tmux python3 python3-pip transmission-cli p7zip-full pv parallel iotop

#hackme tools
apt install nmap dirb nikto hashcat sqlmap

git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git
git clone https://github.com/fuzzdb-project/fuzzdb.git

#rocm - vega56
apt install libnuma-dev

wget -q -O - http://repo.radeon.com/rocm/apt/3.3/rocm.gpg.key | sudo apt-key add -
echo 'deb [arch=amd64] http://repo.radeon.com/rocm/apt/3.3/ xenial main' | sudo tee /etc/apt/sources.list.d/rocm.list
apt update
apt install rocm-opencl rocm-dkms rocm-dev rocm-utils

#ghidra
PKGNAME="ghidra_9.1.2_PUBLIC_20200212.zip"
wget https://ghidra-sre.org/${PKGNAME}
unzip ${PKGNAME}
rm ${PKGNAME}

wget https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.7%2B10/OpenJDK11U-jdk_x64_linux_hotspot_11.0.7_10.tar.gz
wget https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.7%2B10/OpenJDK11U-jre_x64_linux_hotspot_11.0.7_10.tar.gz

tar -xf OpenJDK11U-jdk_x64_linux_hotspot_11.0.7_10.tar.gz
tar -xf OpenJDK11U-jre_x64_linux_hotspot_11.0.7_10.tar.gz

echo "export PATH=$PATH:/opt/jdk-11.0.7+10/bin" >> ${INST_HOME}/.bashrc
ln -s /opt/${PKGNAME}/ghidraRun /usr/bin/ghidra

rm OpenJDK11U-jdk_x64_linux_hotspot_11.0.7_10.tar.gz
rm OpenJDK11U-jre_x64_linux_hotspot_11.0.7_10.tar.gz

#metasploit
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
  chmod 755 msfinstall && \
  ./msfinstall

rm msfinstall

#gobuster
wget https://dl.google.com/go/go1.11.linux-amd64.tar.gz
sudo tar -xvf go1.11.linux-amd64.tar.gz
ln -s /opt/go /usr/local/go

export GOROOT=/usr/local/go
export GOPATH=${INST_HOME}/go
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin
echo "export GOROOT=/usr/local/go" >> ${INST_HOME}/.bashrc
echo "export GOPATH=${INST_HOME}/go" >> ${INST_HOME}/.bashrc
echo "export PATH=$PATH:$GOPATH/bin:$GOROOT/bin" >> ${INST_HOME}/.bashrc

go get github.com/OJ/gobuster

#gtfo bins & priv esc.
pip  install jsonschema pyyaml
pip3 install jsonschema colorama gitpython pyyaml

git clone https://github.com/nccgroup/GTFOBLookup.git
python3 ./GTFOBLookup/gtfoblookup.py update

echo "firefox https://gtfobins.github.io/ 2>/dev/null" > /opt/gtfobins
chmod +x /opt/gtfobins
ln -s /opt/gtfobins /usr/bin/gtfobins

#download wordlists
mkdir -p /opt/wordlists
pushd /opt/wordlists
git clone https://github.com/danielmiessler/SecLists.git

wget https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt
wget https://crackstation.net/files/crackstation-human-only.txt.gz
wget https://crackstation.net/files/crackstation.txt.gz
gunzip *.gz

#transmission-cli magnet:?xt=urn:btih:5a9ba318a5478769ddc7393f1e4ac928d9aa4a71&dn=breachcompilation.txt.7z -w $(pwd)
popd
ln -s /opt/wordlists/ /home/littlehill/wordlists

#burp-suite
[ -f ./burpsuite_community_linux_v2020_2_1.sh ] || echo "WARN: burpsuite_community_linux_v2020_2_1.sh NOT FOUND; install manually"
[ -f ./burpsuite_community_linux_v2020_2_1.sh ] && ./burpsuite_community_linux_v2020_2_1.sh
