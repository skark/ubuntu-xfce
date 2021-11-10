# Ubuntu with Xfce and audio working

### Quick Start

Run the following to get started.

```
echo "user:pass:N" > CREATEUSERS.TXT
docker run --name ubuntu-xfce \
           -p 3389:3389 \
           -e TZ="Europe/London" \
           -v CREATEUSERS.TXT:/root/createusers.txt \
           -dit \
           skark/ubuntu-xfce:latest
```

Then on a windows machine type

```
mstsc
```

Then put in the IP address of the docker host.

Login using the username `user` and the password `pass`

This image is automatically rebuilt when updates are realeased for Ubuntu.

Contents:
- Ubuntu Latest
- Xfce Desktop (ubuntu repo)
- XRDP (built from source)
- XRPDXORG (built from source)
- Pulse Audio (built from source)
- Custom xrdp.ini script
- Default UK Keyboard layout (Can be changed)
- Default UK Timezone (Can be changed)
- You are now able to set the time zone with the TZ variable
- Ability to run a script on container startup. This is useful for installing packages that are needed.
- Local Drive mapping (require elevated rights with this parameter ```--privileged=true```)
- Clipboard Sharing (require elevated rights with this parameter ```--privileged=true```)

```
docker run --name ubuntu-xfce \
           --privileged=true \
           -p 3389:3389 \
           -e TZ="Europe/London" \
           -v %LOCAL_PATH_TO_CREATEUSERS.TXT_FILE%:/root/createusers.txt \
           -v %LOCAL_PATH_TO_STARTUP.SH_FILE%:/root/startup.sh \
           -v %LOCAL_PATH_TO_HOME_DIRECTORY%:/home \
           -dit --restart unless-stopped \
           skark/ubuntu-xfce:latest
```

- Replace %LOCAL_PATH_TO_CREATEUSERS.TXT_FILE% with the local filename of the createusers file.
- Replace %LOCAL_PATH_TO_STARTUP.SH_FILE% with the local filename of the startup.sh script. This is run after the user creation and before the service start.
- Replace %LOCAL_PATH_TO_HOME_DIRECTORY% with the local directory of the /home directorys.

This file contains 3 fields (username:password:is_sudo). Where username is the login id. Password is the password. is_sudo does the user have sudo access(only Y is recognised). It also needs a "newline" at the end of the line.  

Example of a CREATEUSERS.TXT file
```
mickey:mouse:N
daisy:duke:Y
dog:flash:n
morty:rick:wubba
```
In this example 4 users will be created and only daisy will have sudo rights.
At every reboot it will check this file and ADD any new users.

Example of a STARTUP.SH file to change locale.
```
apt-get update
apt-get -y install language-pack-de language-pack-gnome-de
locale-gen de_DE.UTF-8
update-locale LANG=de_DE.UTF-8
```

## To Connect
Please note some clients need an extra parameter set glyph-cache. xfreerdp, remmina and others need this set.

Linux example of how to connect:

```
xfreerdp /size:1920x1140 /kbd:0x00000809 /v:%IP_ADDRESS% /gdi:hw /drive:home,$HOME +clipboard /sound:sys:alsa +glyph-cache
```

Windows example:

Open a command prompt and type

```
mstsc
````

Then put in the ip address of the docker host.

## Auto Update

To automatically update I recomend using watchtower.

```
docker run -d \
    --name watchtower \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower
```

Please note some clients need an extra parameter set glyph-cache. xfreerdp, remmina and others need this set.

Linux example of how to connect ```xfreerdp /v:xxx.xxx.xxx.xxx /drive:home,/home/xxxx +clipboard +glyph-cache```

Based on code from https://github.com/RattyDAVE/docker-ubuntu-xrdp-mate-custom


