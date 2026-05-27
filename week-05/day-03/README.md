# Week 5 — EBS, EFS, and FSx

## What I built

### Lab 1 — EBS operations
Launched an EC2 instance, created a second gp3 EBS volume, attached it, and
formatted it with ext4. Wrote a file to the volume, then detached it and
re-attached it to a second EC2 instance — confirming that data persists on
the volume independently of the instance it's attached to.

### Lab 2 — EFS shared mount
Created an EFS filesystem and mounted it on two separate EC2 instances in the
same region. Wrote a file from instance 1 and read it from instance 2 in real
time — demonstrating shared file storage across instances with no syncing needed.

---

## Lab 1 commands — EBS

```bash
# Check the volume is visible
lsblk

# Format the volume
sudo mkfs.ext4 /dev/xvdf

# Mount and write a file
sudo mkdir /mnt/mydata
sudo mount /dev/xvdf /mnt/mydata
echo "hello from instance 1" | sudo tee /mnt/mydata/test.txt
cat /mnt/mydata/test.txt

# Unmount before detaching
sudo umount /mnt/mydata
```

## Lab 2 commands — EFS

```bash
# Install the EFS mount helper
sudo yum install -y amazon-efs-utils

# Mount the filesystem (both instances)
sudo mkdir /mnt/efs
sudo mount -t efs -o tls fs-0abc1234:/ /mnt/efs

# Write from instance 1
echo "written from instance 1" | sudo tee /mnt/efs/shared.txt

# Read from instance 2
cat /mnt/efs/shared.txt

# Make the mount persist across reboots
echo "fs-0abc1234:/ /mnt/efs efs defaults,_netdev,tls 0 0" | sudo tee -a /etc/fstab
```
