## Create VPC Firewall rules for VNC ports

### Setup firewalls

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

#### Create a remote desktop VM instance

* Menu > Comupte Engine > VM instances

* Create an instance

  ```markdown
  Name=jrvs-remote-desktop-centos7
  Region=us-east1
  Zone=us-east1-c
  Machine type
    cores=2
    Memory=7.5
  Boot disk=centos7 SSD=32GB
  
  Check `Allow Full access to all Cloud APIs`
  Check `Allow HTTP traffic`
  Check `Allow HTTPS traffic`
  
  Click `Management, security, disks, networking, sole tenancy
    Startup script=copy ./remote_desktop_init.sh
    Network tab > Network tags=vnc
  ```

* Click `CREATE`

* Verify

  ```bash
  #Connect to the instance with SSH buttom
  ls /tmp/_*
  
  #/tmp/_start_datetime file indicate startup script start time
  #/tmp/_finish_datetime file indicate startup script finish time
  
  #If you dont see _finish_datetime file in a while..go to troubleshooting section.
  ```

#### Troubleshooting

https://cloud.google.com/compute/docs/startupscript

Use console `ssh` button to connect to the server

```
startup script log file
CentOS and RHEL: /var/log/messages
```

### Connect to Remote Server

#### Remote desktop

* Install `RealVNC` viewer

* Add new connection

  ```
  #find external IP by click the instance details
  #this external IP is not static. It will change if you stop/start the instance
  35.224.241.10:5901
  ```

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