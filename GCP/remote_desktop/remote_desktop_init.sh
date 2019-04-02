#!/bin/bash

#Setup vnc login password
vnc_password="centos1234"

#Install Extra Packages for Enterprise Linux (EPEL)..
sudo yum install -y epel-release

#update all packages on the system
sudo yum update -y

#Instlal xfce desktop
sudo yum groupinstall -y "Xfce"
sleep 1

#Install vnc server (remote access server)
sudo yum install -y tigervnc-server

#Install some common tools
duso yum install -y vim htop tree

#create a vnc config
sudo cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service
sleep 1

#Edit vnc config
sudo bash -c "cat > /etc/systemd/system/vncserver@:1.service << EOF
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
sudo systemctl daemon-reload
sudo systemctl enable vncserver@:1.service

#setup vnc password
printf "$vnc_password\n$vnc_password\n\n" | vncpasswd

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

#Start vnc server
vncserver
sleep 1
vncserver -list

#Refresh service
sudo systemctl daemon-reload
sleep 1
sudo systemctl restart vncserver@:1.service
vncserver -list

#reboot