#!/bin/bash
# wget -O- https://raw.github.com/ROBOTS-WAREZ/Linux/master/netinst.sh | bash;

apt-get update;
apt-get dist-upgrade;

######## Software Package Installations Terminally ########
apt-get install \
    iptables-persistent \
    sudo adduser \
    xorg openbox \
    openjdk-7-jdk openjdk-7-jre icedtea-netx `# Java` \
    iceweasel `# Web Browser & File Viewer` \
    gimp inkscape blender `# Graphical Editors (Rasta, Vector, 3D)` \
    --no-install-recommends --assume-yes \
;

# https://wiki.archlinux.org/index.php/Keyboard_configuration_in_Xorg

######## Firefox || Iceweasel || GNU IceCat ########
# about:config (http://kb.mozillazine.org/User.js_file#Removing_user.js_entries)
echo '
// When Firefox starts: Show my windows and tabs from last time
user_pref("browser.startup.page", 3);
// Use autoscrolling (middle click and drag to navigate the page)
user_pref("general.autoScroll", true);
' > ~/.mozilla/firefox/$(ls ~/.mozilla/firefox/ | grep .default)/user.js; # The profile directory? What if (profiles>1)?

######## Firewall ########
# http://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers

# Just in case, you never know. ;-)
ip6tables --flush
ip6tables --delete-chain
iptables --flush
iptables --delete-chain

# Default policies.
ip6tables -P INPUT DROP;
ip6tables -P OUTPUT DROP;
ip6tables -P FORWARD DROP;
iptables -P INPUT DROP;
iptables -P OUTPUT DROP;
iptables -P FORWARD DROP;

# Loopback.
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Deny corrupt/malformed TCP signals.
iptables -A INPUT -p tcp ! --syn -m state --state NEW -s 0.0.0.0/0 -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP

# Allow valid ICMP signals.
iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 3 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 11 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -m limit --limit 1/second -j ACCEPT

# Allow incoming signals.
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --match multiport --dports 22,80,443 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 53 -s 0.0.0.0/0 -j ACCEPT

# Allow outgoing signals.
iptables -I OUTPUT 1 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT

# Defensive persistence.
iptables-save > /etc/iptables/rules.v4;
ip6tables-save > /etc/iptables/rules.v6;
service iptables-persistent start;
