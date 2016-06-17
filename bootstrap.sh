#!/bin/bash
install_remi=no
install_epel=yes
hostname=$1
suffix=.vagrant.dev
pre_dependencies="wget gnutls"
dependencies="tmux mercurial vim-enhanced htop bash-completion jq mlocate"
ip_filter=10.10.11 # Used for selecting which interface should be used when updating dns-name
current_dir=$PWD
tmp_dir=$(mktemp -d)

echo "Installing dependencies needed for bootstrapping"
yum install -y $pre_dependencies

echo "Downloading global dependencies"
wget "https://raw.github.com/carlba/linuxconf/master/bashrc.d/global.sh" /dev/null 2>&1
source global.sh

in_array() {
    local hay needle=$1
    shift
    for hay; do
        [[ $hay == $needle ]] && return 0
    done
    return 1
}


function install_remi
{
    echo "Installing remi"
    cd $tmp_dir
    wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm > /dev/null 2>&1
    yum -y install remi-release-6.rpm /dev/null 2>&1
    rm -rf remi-release-6.rpm
    cd $current_dir
}

function install_epel
{

cat <<EOM >/etc/yum.repos.d/epel-bootstrap.repo
[epel]
name=Bootstrap EPEL
mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=epel-\$releasever&arch=\$basearch
failovermethod=priority
enabled=0
gpgcheck=0
EOM

yum --enablerepo=epel -y install epel-release
rm -f /etc/yum.repos.d/epel-bootstrap.repo

}

function install_tmux_1.9
{
  filename="install_tmux1.9_centos_6.4.sh"
  cd $tmp_dir
  echo "Downloading script to install tmux"
  wget https://raw.githubusercontent.com/carlba/tmux_config/master/"$filename"  > /dev/null 2>&1
  chmod +x "$filename"
  echo "Compiling and installing tmux 2.0"
  ./$filename > /dev/null 2>&1
  cd $current_dir
}

function allow_birdstep_internal_certificate {
    yum -y install ca-certificates
    update-ca-trust enable
    openssl s_client -showcerts -connect hel.d.birdstep.internal:443 </dev/null 2>/dev/null|openssl x509 -outform PEM >myserver.crt
    cp foo.crt /etc/pki/ca-trust/source/anchors/
    update-ca-certificates
}


function set_hostname
{
    #set hostname
    sed -ri s:HOSTNAME=.*:HOSTNAME=$hostname$suffix:g /etc/sysconfig/network
    hostname $hostname$suffix
    sed -i "s/GSSAPIAuthentication yes/#GSSAPIAuthentication yes/g" /etc/ssh/sshd_config
    sed -i "s/#GSSAPIAuthentication no/GSSAPIAuthentication no/g" /etc/ssh/sshd_config
}

function permit_root
{
  sudo sed -i "s/#PermitRootLogin yes/PermitRootLogin yes/g" /etc/ssh/sshd_config
  echo Time2Server | sudo passwd root --stdin
  sudo service sshd restart
}

function cleanup {
    rm -rf $tmp_dir
}


#Network setup
rm -rf /etc/udev/rules.d/70-persistent-net.rules
set_hostname

#Start with installing bare bone dependencies
yum -y install man wget

[[ "$install_remi" == yes ]] && install_remi
[[ "$install_epel" == yes ]] && install_epel

#install_tmux_1.9

permit_root

#Dependencies
yum -y install $dependencies

cleanup
