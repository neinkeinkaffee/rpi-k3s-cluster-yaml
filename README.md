# rpi-provision

This repository contains scripts to provision Raspberry Pis running Raspbian OS.

1. Run`ssh-keygen` and accept the defaults to create an ssh key in `~/.ssh/id_rsa`
2. Run `run.sh` with a hostname, password, static IP and IP of your router for the Raspberry Pi specified. 
```
HOST_NAME=pi123 PASSWORD=raspberry123 ./run.sh
```
3. Install k3s 
```
# To install on server
ssh pi@pi0 "curl -sfL https://get.k3s.io | sh -"

# To install on agent nods and join 
ssh pi@pi1 "curl -sfL https://get.k3s.io | K3S_TOKEN=$(ssh pi@pi0 sudo cat /var/lib/rancher/k3s/server/node-token) K3S_URL=https://pi0:6443 sh -"

# To retrieve kubeconfig
ssh pi@pi0 sudo cat /etc/rancher/k3s/k3s.yaml | sed -e s/127.0.0.1/pi0/g > ~/kubeconfig
```
4. Deploy nfs-client-provisioner and test whether data persists across pod restarts
```
kubectl apply -f kubernetes/nfs-client-provisioner/nfs-client-provisioner.yaml

# To test whether data persists across pod recreation
# 1. deploy test pod and pvc
kubectl apply -f kubernetes/nfs-client-provisioner/test-pod-and-nfs-client-pvc.yaml
kubectl get pods
# NAME                                     READY   STATUS    RESTARTS   AGE
# test-pod-5649c97974-zfwmm                1/1     Running   0          19s
# 2. write data
kubectl exec -it test-pod-5649c97974-zfwmm -- /bin/bash
echo "hello, world" > /usr/share/nginx/html/index.html
curl localhost
# hello, world
exit
# 3. delete pod and observe how it is recreated
kubectl delete test-pod-5649c97974-zfwmm
# pod "test-pod-5649c97974-zfwmm" deleted
kubectl get pods
# NAME                                     READY   STATUS    RESTARTS   AGE
# test-pod-5649c97974-xvgs6                1/1     Running   0          19s
# 4. check whether the old data is still there
kubectl exec -it test-pod-5649c97974-xvgs6 -- /bin/bash
curl localhost
# hello, world
```

## Mount USB flash drive on OpenWRT

(Source: https://openwrt.org/docs/guide-user/storage/usb-drives-quickstart)

1. Use your **laptop/desktop computer** to format your USB device. Use the default name and format options. This prepares the USB drive for the process below, which will erase those settings (again). Warning: This initial formatting will erase the entire USB drive.

2. SSH into the router and enter the following commands into the SSH window.

3. Get the required packages: You may see error messages about installing kmod-usb3 on certain routers. These can be ignored since the hardware may not support USB3.
```
opkg update && opkg install block-mount e2fsprogs kmod-fs-ext4 kmod-usb-storage kmod-usb2 kmod-usb3
```

4. Enter `ls -al /dev/sd*` to show the name of all attached USB devices. The list may be empty if there are no USB devices. **/dev/sda** is the first USB device; **/dev/sdb** is the second, and so on. **/dev/sda1** is the first partition on the first device; **/dev/sda2** is the second partition, etc.

5. Insert the USB drive into your router. Enter `ls -al /dev/sd*` again, and this time you should see a new `/dev/sdXX` device.
```
root@OpenWrt:~# ls -al /dev/sd*
brw-------    1 root     root        8,   0 Feb  4 15:13 /dev/sda
brw-------    1 root     root        8,   1 Feb  4 14:06 /dev/sda1
```

6. Make an ext4 filesystem on the USB device using the device name you just discovered. Be certain you enter the proper device name - this step will completely erase the device.
```
mkfs.ext4 /dev/sda1
```

7. Create the fstab config file based on all the block devices found. This command writes the current state of all block devices, including USB drives, into the `/etc/config/fstab` file.
```
block detect | uci import fstab
```

8. Update the fstab config file to mount all drives at startup. `/dev/sda` is `mount[0]`, `/dev/sdb` is `mount[1]`, etc. If you have more than one USB device attached, substitute the proper index (0 or 1 or ...) as needed. This command mounts all drives - named or anonymous.
```
uci set fstab.@mount[0].enabled='1' && uci set fstab.@global[0].anon_mount='1' && uci commit fstab
```

9. Mount the device. Automount is enabled on boot.
```
/etc/init.d/fstab boot
```

10. You're done! This procedure has mounted the drive at `/mnt/sdXX` (whatever the device name was.) The drive is ready to save data at that part of the filesystem. 

## Install NFS server on OpenWRT

Install an NFS server on a router running [OpenWRT](https://openwrt.org/docs/guide-user/services/nas/nfs.server) or alternatively on [Raspberry Pi](https://pimylifeup.com/raspberry-pi-nfs/) with USB flash drive mounted
```
# on OpenWRT
# install nfs-kernel-server
opkg update
opkg install nfs-kernel-server
# replace 1000 by the id of a user that you gave read-write access to the mount directory
echo "/mnt/sda1 *(rw,all_squash,insecure,async,no_subtree_check,anonuid=1000,anongid=1000)" >> /etc/exports
```

## Run tinc in Docker

The `docker` directory contains a Dockerfile that builds an image based on `jenserat/tinc` that has terraform and kubectl pre-installed. 

```
docker run -d \               
    --name tinc \
    --net=host \
    --device=/dev/net/tun \
    --cap-add NET_ADMIN \
    --volume ~/tinc/rpinet:/etc/tinc \
    --volume ~/pivpnkubeconfig:/kubeconfig \
    tinc start -D
```
