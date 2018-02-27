# iOS Sign & Install

Bash script for signing and installing iOS 11 apps to Electra JB iOS device. Also can be used to sign and install ATV4 app on 10.2.2 with greenGoblin by NitoTV.

## How this work

This bash script sign any ipa file with jtool than copy app to device and install it. 
Script tested and work only with macOS and Linux.

Notice: for iOS 11 apps will be installed to stock apps directory /Applications and if you want to delete it you must manual enter to SSH and do rm -rf /Applications/APPNAME.app && uicache

### Prerequisites

1. You must have iOS 11 JB device with Electra JB and for Apple TV 4 iOS 10.2.2 with greenGoblib JB!
2. You must download [jtool](http://www.newosxbook.com/tools/jtool.tar) by Jonathan Levin


### Install

First download jtool and export it, than cd terminal to that path than: 

**For macOS**

```
chmod +x jtool && mv jtool /usr/local/bin
```

**For Linux**

```
chmod +x jtool.ELF64 && mv jtool.ELF64 /usr/local/bin/jtool
```

Now clone this repo or download raw ipainstall.sh on your computer and use it like ./ipascript.sh ipa_name ip_address os_type.

For easy use cd to path of this bash script and copy/paste line below.

```
chmod +x ipainstall.sh && mv ipainstall.sh /usr/local/bin/ipainstall
```

Now you can use it like ipainstall from any dir. on your computer.


### How to use

**This script have 3 parameters:**

script name: ipainstall
parameter1: ipa name (app_name.ipa)
parameter2: ip_address (192.168.1.2) * optional
parameter3: os_type (iOS for iPhone, iPod, iPad and tvOS for Apple TV 4) * optional

If you don't want to install app after sign than don't provide parameter 2. Use this if you want to sign app and manual upload to your device.

3rd parameter is set by default to iOS, if you use Apple TV you must pass 2 & 3 parameter.

Also you can open ipainstall.sh and enter your IP address and OS_TYPE at beginning of script so you don't need to enter IP address every time you want to install app.


### Examples

To sign and install app to iOS 11

```
ipainstall application.ipa 192.168.1.2
```

To sign only

```
ipainstall application.ipa
```

To sign and install to Apple TV 4

```
ipainstall application.ipa 192.168.1.2 "tvOS"
```


**I make this script to help myself with testing my application without boring 7 days XCode sign so please don't use this script for piracy!**
