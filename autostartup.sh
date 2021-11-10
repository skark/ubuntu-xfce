#!/bin/bash

#Set Timezone
if [[ -z "${TZ}" ]]; then
   ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime
   dpkg-reconfigure -f noninteractive tzdata
else
   ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime
   dpkg-reconfigure -f noninteractive tzdata
fi

mkdir -p /run/dbus
mkdir -p /var/run/dbus
dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address

mkdir -p cd /etc/sudoers.d
echo "%sudo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sudoersnopwd
chmod 0440 /etc/sudoers.d/sudoersnopwd

#CREATE USERS.
# username:passsword:Y
# username2:password2:Y

file="/root/createusers.txt"
if [ -f $file ]
  then
    while IFS=: read -r username password is_sudo
        do
            echo "Username: $username, Password: $password , Sudo: $is_sudo"

            if getent passwd $username > /dev/null 2>&1
              then
                echo "User Exists"
              else
                useradd -ms /bin/bash $username
                usermod -aG audio $username
                usermod -aG input $username
                usermod -aG video $username
                mkdir -p /run/user/$(id -u $username)/dbus-1/
                chmod -R 700 /run/user/$(id -u $username)/
                chown -R "$username" /run/user/$(id -u $username)/
                echo "$username:$password" | chpasswd
                if [ "$is_sudo" = "Y" ]
                  then
                    usermod -aG sudo $username
                fi
            fi
    done <"$file"
fi

startfile="/root/startup.sh"
if [ -f $startfile ]
  then
    sh $startfile
fi

echo "export QT_XKB_CONFIG_ROOT=/usr/share/X11/locale" >> /etc/profile

# Create the PrivSep empty dir if necessary
if [ ! -d /run/sshd ]; then
   mkdir /run/sshd
   chmod 0755 /run/sshd
fi

/usr/bin/pulseaudio -D --high-priority=true --system=true --realtime=true --exit-idle-time=-1 --no-cpu-limit
#This has to be the last command!
/usr/bin/supervisord -n
