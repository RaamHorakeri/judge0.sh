System Requirements
Please note that Judge0 has only been tested on Linux and might not work on other systems; thus, we do not provide support for it.

We recommend using Ubuntu 22.04 disk atleast 16gb , 2vcpu & 4gb memory, on which you need to do the following update of GRUB:


1.Use sudo to open file /etc/default/grub

2.Add systemd.unified_cgroup_hierarchy=0 in the value of GRUB_CMDLINE_LINUX variable.

3.Apply the changes: sudo update-grub 

4.Restart your server: sudo reboot 

5.Additionally, make sure you have Docker and Docker Compose installed.

6. chmod +x judge0.sh

7. ./judge0.sh
