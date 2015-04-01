#!/bin/bash
# su; # SuperUser login.
# wget -O- https://raw.github.com/ROBOTS-WAREZ/Linux/master/netinst.sh | bash; # Run this script.
# smxi; # Mainly for the GPU drivers. [http://smxi.org/site/install.htm]
# reboot; # SuperUser signout.

username=$(getent passwd 1000 | cut -d: -f1);
userpath=/home/$username;

apt-get update;
apt-get dist-upgrade;

######## Software Package Installations Terminally ########
apt-get install \
    gawk unzip \
    iptables-persistent \
    sudo adduser \
    xorg openbox \
    alsa-base alsa-utils `# Audio` \
    openjdk-7-jdk openjdk-7-jre icedtea-netx `# Java` \
    iceweasel `# Web Browser & File Viewer` \
    vlc `# Media Player` \
    gimp inkscape blender `# Visiographical Editors (Rasta, Vector, 3D)` \
    audacity `# Audiographical Editor` \
--assume-yes --no-install-recommends;
# http://stackoverflow.com/a/12797512

apt-get autoremove && apt-get autoclean;

#http://smxi.org/site/install.htm
cd /usr/local/bin && wget -Nc smxi.org/smxi.zip && unzip smxi.zip && rm smxi.zip;

######## Enable sudo ########
adduser $username sudo;

######## Audio ########
alsactl init;

######## Firefox || Iceweasel || GNU IceCat ########
# about:config (http://kb.mozillazine.org/User.js_file#Removing_user.js_entries)
echo '
// When Firefox starts: Show my windows and tabs from last time
user_pref("browser.startup.page", 3);
// Use autoscrolling (middle click and drag to navigate the page)
user_pref("general.autoScroll", true);
' > $userpath/.mozilla/firefox/$(ls ~/.mozilla/firefox/ | grep .default)/user.js; # The profile directory? What if (profiles>1)?

######## Openbox ########
# https://wiki.archlinux.org/index.php/openbox
# http://openbox.org/wiki/Help:Configuration

mkdir -p $userpath/.config/openbox;
cp -R /etc/xdg/openbox/* $userpath/.config/openbox;

echo '
<?xml version="1.0" encoding="UTF-8"?>

<openbox_menu xmlns="http://openbox.org/"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://openbox.org/
                file:///usr/share/openbox/menu.xsd">

<menu id="root-menu" label="Openbox 3">
  <item label="Terminal emulator">
    <action name="Execute"><execute>x-terminal-emulator</execute></action>
  </item>
  <item label="Web browser">
    <action name="Execute"><execute>x-www-browser</execute></action>
  </item>
  <item label="File Manager">
    <action name="Execute"><execute>x-www-browser -new-window file://'$userpath'/</execute></action>
  </item>
  <!-- This requires the presence of the 'menu' package to work -->
  <menu id="/Debian" />
  <separator />
  <menu id="client-list-menu" />
  <separator />
  <item label="ObConf">
    <action name="Execute"><execute>obconf</execute></action>
  </item>
  <item label="Reconfigure">
    <action name="Reconfigure" />
  </item>
  <item label="Restart">
    <action name="Restart" />
  </item>
  <separator />
  <item label="Exit">
    <action name="Exit" />
  </item>
</menu>

</openbox_menu>
' > $userpath/.config/openbox/menu.xml;

######## Firewall ########
# http://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
# http://unix.stackexchange.com/q/108029
# http://askubuntu.com/q/423630

# Just in case, you never know. ;-)
ip6tables --flush;
ip6tables --delete-chain;
iptables --flush;
iptables --delete-chain;

# Default policies.
ip6tables -P INPUT DROP;
ip6tables -P OUTPUT DROP;
ip6tables -P FORWARD DROP;
iptables -P INPUT DROP;
iptables -P OUTPUT DROP;
iptables -P FORWARD DROP;

# Deny malformed/illegal/corrupt TCP signals.
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP;
iptables -A INPUT -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP;
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP;
iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP;
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP;
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP;
iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP;

# Allow incoming signals.
iptables -A INPUT -i lo -m state --state ESTABLISHED,RELATED -j ACCEPT;
iptables -A INPUT -p icmp --icmp-type echo-reply -m state --state ESTABLISHED,RELATED -j ACCEPT;
iptables -A INPUT -p udp -m multiport --sports 53,123 -m state --state ESTABLISHED,RELATED -j ACCEPT;
iptables -A INPUT -p tcp -m multiport --sports 22,80,443,26000:28000 -m state --state ESTABLISHED,RELATED -j ACCEPT;

# Allow outgoing signals.
iptables -A OUTPUT -o lo --state NEW,ESTABLISHED,RELATED -j ACCEPT;
iptables -A OUTPUT -p icmp --icmp-type echo-request -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT;
iptables -A OUTPUT -p udp -m multiport --dports 53,123 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT;
iptables -A OUTPUT -p tcp -m multiport --dports 22,80,443,26000:28000 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT;

# Defensive persistence.
iptables-save > /etc/iptables/rules.v4;
ip6tables-save > /etc/iptables/rules.v6;
service iptables-persistent start;

# https://wiki.archlinux.org/index.php/Keyboard_configuration_in_Xorg
# https://wiki.debian.org/EnvironmentVariables
