# the file is located at: /etc/init.d/firewall_1

#!/bin/sh

# kFreeBSD do not accept scripts as interpreters, using #!/bin/sh and sourcing.
#if [ true != "$INIT_D_SCRIPT_SOURCED" ] ; then
#    set "$0" "$@"; INIT_D_SCRIPT_SOURCED=true . /lib/init/init-d-script
#fi

### BEGIN INIT INFO
# Provides:          Firewall_1.sh
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Firewall script for simple server
# Description:       The firewall script enable routing of 192.168.137.0/24
#                    to go through and ftp services to access.
### END INIT INFO

#DESC="Description of the service"
#DAEMON=/usr/sbin/daemonexecutablename

# module
modprobe ip_tables
modprobe ip_conntrack
modprobe ip_conntrack_ftp
modprobe ip_conntrack_irc

iptables -F
iptables -X
iptables -F -t nat
iptables -X -t mangle

echo "1" > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth0 -s 192.168.137.0/24 -j MASQUERADE
iptables -A FORWARD -i eth1 -j ACCEPT #forward requests from 192.168.137.0/24
iptables -t nat -A PREROUTING -i eth0 -p tcp -s 192.168.137.0/24 -j REDIRECT --to-port 80
#iptables -A INPUT -p all -s 192.168.137.0/255.255.255.0 -j ACCEPT

##ports 80(web), 25(mail), 110(pop3), 20/21(ftp), 22(ssh), 53(dns)
iptables -A INPUT -i eth0 -p tcp --dport 22 -j ACCEPT
# enable some incoming calls
iptables -A INPUT -i eth0 -p tcp --dport 8553 -j ACCEPT

iptables -A INPUT -i eth0 -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -i eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

# drop all other packages
iptables -A INPUT -i eth0 -m state --state NEW,INVALID -j DROP
# enable some game connection
iptables -A INPUT -p udp -m udp --sport 27000:27030 --dport 1025:65355 -j ACCEPT
iptables -A INPUT -p udp -m udp --sport 4380 --dport 1025:65355 -j ACCEPT
