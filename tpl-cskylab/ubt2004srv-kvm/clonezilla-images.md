# Clonezilla images <!-- omit in toc -->

## v21.12.15 <!-- omit in toc -->

This procedure covers how to make and restore disk image copies from physical machines to local usb devices, with partition and disk imaging/cloning program Clonezilla.

For more information see: <https://clonezilla.org/>

- [Prerequisites](#prerequisites)
- [Set-up Clonezilla Imaging environment](#set-up-clonezilla-imaging-environment)
  - [Boot from Clonezilla USB](#boot-from-clonezilla-usb)
  - [Select device-image mode and mount local image storage](#select-device-image-mode-and-mount-local-image-storage)
- [Create image file from disk](#create-image-file-from-disk)
- [Restore image file to disk](#restore-image-file-to-disk)

---

## Prerequisites

- Download Clonezilla .iso file from <https://clonezilla.org/downloads.php>
- Generate Clonezilla USB boot flash disk from .iso file (Use balenaEtcher software in MacOS)
- External USB disk with enough capacity for disk images

## Set-up Clonezilla Imaging environment

### Boot from Clonezilla USB

- Plug Clonezilla USB boot flash disk into the machine
- Connect `IPMI` interface to your network
- Login to IPMI
- Start a remote console: In **Remote Control -> iKVM/HTML5** start a remote console
- Open virtual keyboard: If necessary, open a virtual keyboard pressing the button down left
- Start the machine: Execute **Power Control -> Set Power On** to start the machine
- Enter in Boot Menu: Press **`<F11>` to invoke Boot Menu** when prompted

- Select Flash disk boot device and boot the machine
  
  ![ ](./images/clonezilla/kvm-main_boot-menu2.png)

- Select **Other modes of Clonezilla Live**
  
  ![ ](./images/clonezilla/2021-06-08_11-25-27.png)

- Select **Clonezilla live (To RAM. Boot media can be removed later)**
  
  ![ ](./images/clonezilla/2021-06-08_11-26-51.png)

- Select **Select en-US as language**
  
  ![ ](./images/clonezilla/2021-06-08_11-30-29.png)

- Select **Accept default keyboard layout**
  
  ![ ](./images/clonezilla/2021-06-08_11-32-22.png)

- The boot process finishes in **Start Clonezilla** window. 
  
  >**NOTE:**: You can unplug now the USB Clonezilla boot flash disk and plug the external USB disk with images storage.
  
  ![ ](./images/clonezilla/2021-06-08_11-34-09-start-clonezilla.png)

### Select device-image mode and mount local image storage

This procedure selects device-image mode and mounts local USB external disk as repository for images.

- Start Clonezilla after boot procedure
  
  ![ ](./images/clonezilla/2021-06-08_11-34-09-start-clonezilla.png)

- Select **device-image** to work with disk or partition using images
  
  ![ ](./images/clonezilla/2021-06-08_11-52-40.png)

- Select **local_dev** to use local device
  
  ![ ](./images/clonezilla/2021-06-08_11-55-12.png)

- Select **local_dev** to use local device. Wait for your device to be detected and follow instructions.
  
  ![ ](./images/clonezilla/2021-06-08_11-55-12.png)

- Select your **external disk drive** (by pressing space) to be mounted as images repository
  
  >**NOTE**: Be sure you do not select internal disk devices
  
  ![ ](./images/clonezilla/2021-06-08_12-00-20.png)

- Accept  **no-fsck** by default
  
  ![ ](./images/clonezilla/2021-06-08_12-06-58.png)

- Navigate to select the directory to hold the images and continue
  
  ![ ](./images/clonezilla/2021-06-08_12-10-29.png)

  ![ ](./images/clonezilla/2021-06-08_12-11-25.png  )

- The procedure finishes with **Beginner-Expert** window. From here you can create or restore images from/to disks.
  
  ![ ](./images/clonezilla/2021-06-08_12-15-16-beginner-mode.png)

## Create image file from disk

This procedure copies an entire internal disk as an image file in external image repository.

- Start **Beginner** mode after **Select device-image mode and mount local image storage** procedure:
  
  ![ ](./images/clonezilla/2021-06-08_12-15-16-beginner-mode.png)

- Select **savedisk** to save local disk as an image
  
  ![ ](./images/clonezilla/2021-06-08_12-30-14.png)

- Name the disk image by adding to the date/time proposed name the following information:
  - Machine name: Ex. `kvm-main`
  - Disk name: Ex. `system` or `data`
  - Image name: Ex. `opnsense` for a specific installation phase
  
  ![ ](./images/clonezilla/2021-06-08_12-33-00.png)

- Select the **internal disk** to copy as an image
  
  ![ ](./images/clonezilla/2021-06-08_12-42-39.png)

- Accept default values for compression option
  
  ![ ](./images/clonezilla/2021-06-08_12-45-45.png)

- Accept default values and skip checking/repairing source file system
  
  ![ ](./images/clonezilla/2021-06-08_12-48-27.png)

- Accept default values and check image after saved
  
  ![ ](./images/clonezilla/2021-06-08_12-50-16.png)

- Accept default values and do not encrypt the image
  
  ![ ](./images/clonezilla/2021-06-08_12-52-18.png)

- Accept default values and choose reboot/shutdown or other options when finished
  
  ![ ](./images/clonezilla/2021-06-08_12-54-11.png)

- Accept default values and choose reboot/shutdown or other options when finished. Follow instructions, confirm and continue.
  
  ![ ](./images/clonezilla/2021-06-08_12-54-11.png)

- Watch progression and wait until image is created and successfully checked. 
- When the process finishes choose **rerun3** if you want to perform other copies with the same image repository.

  ![ ](./images/clonezilla/2021-06-08_13-07-14.png)

## Restore image file to disk

This procedure restores an entire internal disk from an image file.

- Start **Beginner** mode after **Select device-image mode and mount local image storage** procedure:
  
  ![ ](./images/clonezilla/2021-06-08_12-15-16-beginner-mode.png)

- Start **restoredisk** to restore an image to local disk
  
  ![ ](./images/clonezilla/2021-06-08_17-50-56.png)

- Choose the image file to restore
  
  ![ ](./images/clonezilla/2021-06-08_17-53-10.png)

- Choose the target disk
  
  ![ ](./images/clonezilla/2021-06-08_17-55-31.png)

- Accept default values to check image before restoring
  
  ![ ](./images/clonezilla/2021-06-08_18-01-58.png)

- Accept default values and choose reboot/shutdown or other options when finished. Follow instructions, confirm and continue.
  
  ![ ](./images/clonezilla/2021-06-08_18-04-14.png)

- Watch progression and wait until image is successfully restored. 
- When the process finishes choose **rerun3** if you want to restore other images from  the same image repository.
