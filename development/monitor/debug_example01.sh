#!bin/bash
# we are debugging a remote computer for a user which is working with a standard Ubuntu desktop. The user started calculator, and now his or her entire screen in frozen. We want to now remotely kill all processes which relate in any way to the locked screen, without restarting the server

$ lsof | grep calculator | grep "share" | head -n1 xdg-deskt 3111 abc mem REG 253,1 3009 12327296 /usr/share/locale-langpack/en_AU/LC_MESSAGES/gnome-calculator.mo
$ fuser -a /usr/share/locale-langpack/en_AU/LC_MESSAGES/gnome-calculator.mo /usr/share/locale-langpack/en_AU/LC_MESSAGES/gnome-calculator.mo: 3111m 3136m 619672m 1577230m
$ ps -ef | grep -E "3111|3136|619672|1577230" | grep -v grep abc 3111 2779 0 Aug03 ? 00:00:11 /usr/libexec/xdg-desktop-portal-gtk abc 3136 2779 5 Aug03 ? 03:08:03 /usr/bin/gnome-shell abc 619672 3136 0 13:13 ? 00:00:01 gnome-calculator abc 1577230 2779 0 Aug04 ? 00:03:15 /usr/bin/nautilus --gapplication-service
