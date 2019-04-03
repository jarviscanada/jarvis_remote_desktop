Create VPC Firewall rules for VNC ports

- In GCP console, search for  `vpc firewall rules`

- Click `CREATE FIREWALL RULE`

- Configuration

  ```
  Name=vnc
  Targets=Specific target tags
  Target tags=vnc
  Source IP ranges=0.0.0.0/0
  Protocals and ports
  	tcp: 5900-5910
  ```

- Click `CREATE`

Create a remote desktop VM instance

* Menu > Comupte Engine > VM instances

* Create an instance

  ```
  Name=bootcamp-centos-remote-desktop
  Region=us-east1
  Zone=us-east1-c
  Machine type
    cores=2
    Memory=7.5
  Boot disk=centos7 (10GB disk)
  
  Check `Allow HTTP traffic`
  Check `Allow HTTPS traffic`
  
  Click `Management, security, disks, networking, sole tenancy
    Startup script=copy ./remote_desktop_init.sh
    Network tab > Network tags=vnc
  ```

* Click `CREATE`

User console `ssh` to the remote server

Bootstrap log `/var/log/messages`

Remote desktop

* Install `RealVNC` viewer

* Change VNC resolution to your laptop display resolution

  ```
  xrandr --fb 1440x900
  ```

* Troubleshooting

* 1. Check vncserver service status

  2. 1. `sudo systemctl status vncserver@:1.service`

  3. Check current running vncserver displays

  4. 1. `vncserver -list`

  5. Vncserver log and config location

  6. 1. `cd ~/.vnc/` 