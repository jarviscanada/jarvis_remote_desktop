#!/bin/bash
# su - centos

vnc_password="centos1234"

#if [[ ! -z "${$1}" ]];then
#    vnc_password=$1
#fi

#Install Extra Packages for Enterprise Linux (EPEL)..
sudo yum install -y epel-release

#update all packages on the system
#sudo yum update -y

#Instlal GNOME destop
#sudo yum groupinstall -y "GNOME Desktop"
sudo yum groupinstall -y "Xfce"

#Install vnc server (remote access server)
sudo yum install -y tigervnc-server vim

#create vnc config
sudo cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service

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


printf "$vnc_password\n$vnc_password\n\n" | vncpasswd
sleep 1
bash -c "cat > /home/centos/.vnc/xstartup << EOF
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
vncserver -kill \$DISPLAY
EOF"
chmod +x /home/centos/.vnc/xstartup
vncserver
vncserver -list

sudo systemctl daemon-reload
sudo systemctl enable vncserver@:1.service
sudo systemctl start vncserver@:1.service
#reboot