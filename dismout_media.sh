IPMI_LOCATION=47.13.73.117
USERNAME=ADMIN
PASSWORD=ADMIN
IMAGE_NAME=$1

function do_sleep () {
  sleep 5
}

#1. Enable Virtual Media 1.1 Speed up things if it service is already running
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0xca 0x08
do_sleep
# 1.2 Start Virtual Media (Enable "Remote Media Support")
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0xcb 0x08 0x01
do_sleep
# 1.3 Just Enable the service does not seem to start it (in all HW), Resetting it after enableing helps
#--> Restart Virtual Media service $ ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0xcb 0x0a 0x01 2. Restart Remote Image Service
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0x9f 0x08 0x0b
do_sleep
# 3. Stop redirection
IMAGE_NAME_ASCII=`./string_to_ascii.py $IMAGE_NAME`
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0xD7 0x01 0x01 0x01 0x00 $IMAGE_NAME_ASCII
do_sleep
#4. Clear RIS configuration
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0x9f 0x01 0x0d
do_sleep
# 5. Demount virtual device (Disable CD/DVD device)
#--> Disable "Mount CD/DVD" should cause vmedia restart within 2 seconds.
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0xcb 0x00 0x00
do_sleep
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0xca 0x00
do_sleep
# (read status should return 0x00) 6. Reduce the number of virtual devices (CD set to 1, HD set to 0) 6.1 set device number:
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0xcb 0x04 0x01
do_sleep
# 6.2 Check the setting:
ipmitool -I lanplus -H $IPMI_LOCATION -U $USERNAME -P $PASSWORD raw 0x32 0xca 0x04
do_sleep
