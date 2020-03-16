#!/bin/bash

touch /tmp/"_start_$(date '+%d-%m-%Y-%H:%M:%S')"
if ls /tmp/_finish_*; then
  echo "Instance is initialized"
  echo "exit"
  exit 0;
fi

adduser centos
password="centos1234"
echo -e "${password}" | passwd "centos" 
#grant user sodo priv
usermod -aG wheel centos
#disable sudo password prompt
echo '%wheel        ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers

#Setup vnc login password
vnc_password="${password}"

#Install Extra Packages for Enterprise Linux (EPEL)..
yum install -y epel-release

#update all packages on the system
yum update -y

#Instlal xfce desktop
yum groupinstall -y "Xfce"
sleep 1

#Install vnc server (remote access server)
yum install -y tigervnc-server

#Install some common tools
sudo yum install -y vim gvim htop tree wget git terminator zip unzip

#install openjdk1.8 (java 8)
yum install -y java-1.8.0-openjdk-devel

#install maven (yum can only install older version)
cd /tmp
wget http://apache.forsale.plus/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
tar xf /tmp/apache-maven-3.6.3-bin.tar.gz -C /opt
ln -s /opt/apache-maven-3.6.3/ /opt/maven
bash -c 'cat > /etc/profile.d/maven.sh << EOF
export JAVA_HOME=/usr/lib/jvm/jre-openjdk
export M2_HOME=/opt/maven
export MAVEN_HOME=/opt/maven
export PATH=${M2_HOME}/bin:${PATH}
EOF'
chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh
mvn --version
cd -

#create a vnc config
yes | cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service
sleep 1

#Edit vnc config
bash -c "cat > /etc/systemd/system/vncserver@:1.service << EOF
[Unit]
Description=Remote desktop service (VNC)
After=syslog.target network.target

[Service]
Type=forking

# Clean any existing files in /tmp/.X11-unix environment
ExecStartPre=/bin/sh -c '/usr/bin/vncserver -kill %i > /dev/null 2>&1 || :'
ExecStart=/usr/sbin/runuser -l centos -c \"/usr/bin/vncserver %i -geometry 1280x1024\"
PIDFile=/home/centos/.vnc/%H%i.pid
ExecStop=/bin/sh -c '/usr/bin/vncserver -kill %i > /dev/null 2>&1 || :'

[Install]
WantedBy=multi-user.target
EOF"
sleep 1

#Enable vnc config
systemctl daemon-reload
systemctl enable vncserver@:1.service

#setup vnc password
su - centos -c "printf \"$vnc_password\n$vnc_password\n\n\" | vncpasswd"

#fix xfce black screen issue
bash -c 'cat > /home/centos/.vnc/xstartup << EOF
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
vncserver -kill \$DISPLAY
EOF'
chmod +x /home/centos/.vnc/xstartup
cat /home/centos/.vnc/xstartup
chown -R centos:centos /home/centos/

#Start vnc server
su - centos -c vncserver
sleep 1
su - centos -c "vncserver -list"
sleep

cd /tmp
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
yum localinstall -y google-chrome-stable_current_x86_64.rpm
rm *rpm

#Refresh service
#systemctl daemon-reload
#sleep 1
#systemctl restart vncserver@:1.service
#su - centos -c "vncserver -list"

#create a finish file
touch /tmp/"_finish_$(date '+%d-%m-%Y-%H:%M:%S')"

exit 0
