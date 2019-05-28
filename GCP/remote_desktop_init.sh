#!/bin/bash

adduser centos
password="centos1234"
echo "${password}" | passwd "centos" --stdin
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
sudo yum install -y vim htop tree wget git terminator maven

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

yum install -y java-1.8.0-openjdk-devel

#Refresh service
#systemctl daemon-reload
#sleep 1
#systemctl restart vncserver@:1.service
#su - centos -c "vncserver -list"

#reboot