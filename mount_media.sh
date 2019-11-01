IPMI_LOCATION=192.168.86.61
USERNAME=ADMIN
PASSWORD=ADMIN
NFS_IP=192.168.86.57
ISO_LOCATION=/var/nfsshare
IMAGE_NAME=$1

function do_sleep () {
  sleep 5
}

#1. Power off server
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD chassis power off
do_sleep
#2. Enable virtual media support
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0xca 0x08
do_sleep
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0xcb 0x08 0x01
do_sleep
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0xcb 0x0a 0x01
do_sleep
#3. Enable CD/DVD device 2.1 Enable "Mount CD/DVD" in GUI (p144) should cause vmedia restart within 2 seconds.
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0xcb 0x00 0x01
do_sleep
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0xca 0x00
do_sleep
#(read status should return 0x01)
#4. Clear RIS configuration
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0x9f 0x01 0x0d
do_sleep
#5 Setup nfs 4.1 Set share type NFS
SHARE_TYPE_ASCII=`./string_to_ascii.py nfs`
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0x9F 0x01 0x05 0x00 $SHARE_TYPE_ASCII
do_sleep
#6 NFS server IP (10.38.12.26)
NFS_IP_ASCII=`./string_to_ascii.py $NFS_IP`
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0x9F 0x01 0x02 0x00 $NFS_IP_ASCII
do_sleep
#7 Set NFS Mount Root path 4.3.1 clear progress bit
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0x9F 0x01 0x01 0x00 0x00
do_sleep
#8 set progress bit
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0x9F 0x01 0x01 0x00 0x01
do_sleep
#9 Set path
ISO_LOCATION_ASCII=`./string_to_ascii.py $ISO_LOCATION`
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0x9F 0x01 0x01 0x01 $ISO_LOCATION_ASCII
do_sleep
#10 clear progress bit
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0x9F 0x01 0x01 0x00 0x00
do_sleep
#11 Restart Remote Image CD (Restart RIS CD media)
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0x9f 0x01 0x0b 0x01
do_sleep
#12 Wait for device to be mounted (output is Available image count [3:5])
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0xd8 0x00 0x01
do_sleep
#13 Set image name (start redirection)
IMAGE_NAME_ASCII=`./string_to_ascii.py $IMAGE_NAME`
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0xD7 0x01 0x01 0x01 0x01 $IMAGE_NAME_ASCII
do_sleep
#14 Tell BMC to boot from Virtual CD/ROM next power on
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x00 0x08 0x05 0x80 0x14 0x00 0x00 0x00
do_sleep
#15 Power on server
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD chassis power on