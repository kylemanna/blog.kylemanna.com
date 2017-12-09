---
title: "Installing pfSense on Google Cloud Platform"
excerpt: "How to create a pfSense Instance using Google Compute Engine"
category: cloud
tags: [pfsense, cloud, networking, security, vpn]
header:
  image: https://i.imgur.com/rUWuW4y.png
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: https://i.imgur.com/rUWuW4y.png
---

The goal of this guide is to get a simple pfSense server setup and running the cloud. My primary interest is to use it as a VPN server for IPsec and OpenVPN clients.

## Step 1 - Prepare an Image

First the pfSense distribution image needs to be converted to something that can be used on Google Cloud.  This is more convoluted then it needs to be but, but sit tight!

I'd recommend doing this on a Google Cloud host or the cloud console to make the upload and download quick.

Download the image, decompress and move it to the required file:

    curl https://nyifiles.pfsense.org/mirror/downloads/pfSense-CE-memstick-serial-2.4.2-RELEASE-amd64.img.gz | gunzip > disk.raw

Tar the file back up in a [format Google Cloud expects](https://cloud.google.com/compute/docs/images/import-existing-image):

    tar -Sczf pfSense-CE-memstick-serial-2.4.2-RELEASE-amd64.img.tar.gz disk.raw

## Step 2 - Upload Disk Image to Google Cloud Storage Bucket

Using Google Cloud shell:

    gsutil cp pfSense-CE-memstick-serial-2.4.2-RELEASE-amd64.img.tar.gz gs://YOUR_BUCKET

## Step 3 - Create a New Image

Navigate to [GCP Console](https://console.cloud.google.com) -> [Compute Engine](https://console.cloud.google.com/compute) -> [Create an image](https://console.cloud.google.com/compute/imagesAdd).

* Name: `pfsense-242-installer`
* Source: "Cloud Storage file" and specify the path to `YOUR_BUCKET/pfSense-CE-memstick-serial-2.4.2-RELEASE-amd64.img.tar.gz`

## Step 4 - Create a New Instance for the Installer

In this step a new instance will be created using the installer image to install pfSense on to a second disk.

Navigate to [GCP Console](https://console.cloud.google.com) -> [Compute Engine](https://console.cloud.google.com/compute) -> [Create an instance](https://console.cloud.google.com/compute/instancesAdd).

* Name: `pfsense-install-1`
* Boot disk: `pfsense-242-installer`
* Create a additional disk using the advanced drop down.
    * Name: `pfsense-242-clean-install`
    * Source Type: None (blank disk)
    * Size: 20GB

Start the instance and wait for it to complete start-up.

## Step 5 - Enable and Connect to Installer Serial Console

    gcloud compute instances add-metadata --project=$PROJ --zone=$ZONE --metadata=serial-port-enable=1 pfsense-install-1
    gcloud compute connect-to-serial-port --project=$PROJ --zone=$ZONE pfsense-install-1

## Step 6 - Follow Default Install and Shutdown Install Instance

The defaults are acceptable.

Stop the instance when the install is complete instead of rebooting. I typically stop the VM using the Google Cloud Console the last step of the installer when it asks to reboot.

## Step 7 - Create Snapshot of the Newly Installed Disk

Navigate to [GCP Console](https://console.cloud.google.com) -> [Compute Engine](https://console.cloud.google.com/compute) -> [Disk](https://console.cloud.google.com/compute/disks).

Create a snapshot of the `pfsense-242-clean-install` so that it can be used as a boot disk for our final instance.

* Name: `pfsense-242-image`

## Step 8 - Create and Launch New Instance Using Snapshot

Navigate to [GCP Console](https://console.cloud.google.com) -> [Compute Engine](https://console.cloud.google.com/compute) -> [Create an instance](https://console.cloud.google.com/compute/instancesAdd).

* Name: `pfsense-1`
* Machine type: Pick something applicable to the work load.
* Boot disk:
    * Snapshots: `pfsense-242-image`
    * Size: 20GB (or something applicable for work load, typically only needed for logging).
* Under the advanced drop down -> networking tag create a `pfsense` Networking tag. This aides firewall configuration.

Start the instance and wait for it to complete start-up.

## Step 9 - Enable and Connect to Serial Console For Initial Configuration

    gcloud compute instances add-metadata --project=$PROJ --zone=$ZONE --metadata=serial-port-enable=1 pfsense-1
    gcloud compute connect-to-serial-port --project=$PROJ --zone=$ZONE pfsense-1

Follow the typical pfSense console configuration steps, defaults are pretty close to correct.

## Step 10 - Fix Some Setting to Work with Google Cloud Platform

Run a few commands to enable access to the on the WAN interface.

### Temporarily set the MTU to work with Google Cloud

Use the serial console to enter the shell by typing *8*.  You should be greeted by the standard pfSense shell.

Google Cloud needs an [MTU of 1460 or lower](https://cloud.google.com/vpn/docs/concepts/advanced#maximum_transfer_unit_mtu_considerations) due to administrative overhead in the Google network.  Skipping this step will result in all kinds of bewildering networking issues.

    ifconfig vtnet0 mtu 1460

This is temporary, but will get fixed permanently later in the WebUI later.

### Disable the WebUI referrer check

Due to the way the GCP internal IPs work pfSense will throw an error.  Fix this on the serial console shell with:

    pfSsh.php playback disablereferercheck

### Enable SSH Daemon

    pfSsh.php playback enablesshd

### Disable the firewall

Disable the firewall so that the SSH can be accessed and configured:

    pfctl -d

Yes, this is a massive hole, I assume you know what you are doing.  This will get re-enabled after the WebUI configuration.

## Step 11 - Create a Cloud Firewall Rule to Allow SSH to the VM Instance

Navigate to [GCP Console](https://console.cloud.google.com) -> [VPC Network](https://console.cloud.google.com/networking/) -> [Create a firewall rule](https://console.cloud.google.com/networking/firewalls/add).

* Name: `allow-pfsense`
* Target tags: `pfsense` (from VM Instance creation)
* Source IP ranges: `0.0.0.0/0`
* Specified protocols and ports: `tcp:22`

This will expose the ssh server in the pfSense instance to the Internet.  Ensure good passwords are set later or better yet, only public-private keys are used.

Create the firewall rule and give it some time to propagate to the cloud firewalls.

## Step 10 - Complete the WebUI Wizard using SSH port forwarding

Setup port forwarding and open a ssh session. Default username is **admin** and default password is **pfsense**.

    ssh admin@EXTERNAL_IP -L 8443:localhost:443

Connect to the pfSense WebUI @ [`https://localhost:8443/`](https://localhost:8443/).

Accept the security exception, and complete the install wizard.  Make sure the **MTU of the WAN interface is set to `1460`** to work with Google Cloud.

When the installer concludes it will re-enable the firewall, you may need to run `pfctl -d` again from the serial console.

## Step 11 - Reconnect to the WebUI and Finish

### Enable and Configure sshd on WAN Interface

I expose Secure Shell publicly and disable password logins to keep the system locked down:

* Add your Secure Shell public key to the admin or a new user
    * System -> User Manager -> Users -> [Admin](https://localhost:8443/system_usermanager.php?act=edit&userid=0)
    * Paste your SSH public key in the Authorized SSH Keys field.
    * Save
* Navigate to Firewall -> Rules -> [WAN](https://localhost:8443/firewall_rules.php?if=wan)
    * Create a rule to allow ssh after we disable the anti-lockout rule.
        * Action: `Pass`
        * Interface: `WAN`
        * Protocol: `TCP`
        * Source: `any`
        * Destination: `WAN Address`
        * Destination Port Range: `SSH (22)`
        * Description: `Allow public SSH access to pfSense`
    * Save 
    * Apply Changes
* Configure Secure Shell
    * Navigate to System -> Advanced -> [Admin Access](https://localhost:8443/system_advanced_admin.php)
    * Check: `Disable webConfigurator anti-lockout rule` as it exposes the WebUI (use SSH to forward the WebUI) to the Internet
    * Check: `Enable Secure Shell`
    * Check: `Disable password login for Secure Shell (RSA/DSA key only)`
    * Save
    * Re-connect the SSH port forwarding session as it likely exited and broke access to the WebUI when saved.

### Accessing the WebUI via ssh

I typically access the WebUI over ssh to keep the system secure:

    ssh admin@PUBLIC_IP -fNL 8443:localhost:443

Then navigate to [`https://localhost:8443/`](https://localhost:8443/).  An adversary would have to find a hole in the SSH server or my private key to begin attacking the system.

You could expose the WebUI to the entire Internet, but [understand the risks](https://www.netgate.com/blog/securely-managing-web-administered-devices.html).

## Wrapping Up

* Delete the original `pfsense-install-1` installer VM instance, it's not needed after the install snapshot has been created.
* Verify the firewall is re-enabled and comes up correctly after reboot
* Celebrate.
* Get down to doing the real pfSense work.
