#Jacob Cedar jac2552@rit.edu
QUIET (){
    eval $@ 2>/dev/null >/dev/null
    return $?
}
users_add() {
    # Add all the following users add wheel/sudo with a password changem
    for user in "kong" "thanos" "deadpool" "bane" "vader" "yondu"; do
        QUIET useradd $user;
        s1=$?;
        echo "$user:changeme" | chpasswd 2>/dev/null >/dev/null;
        s2=$?;
        QUIET usermod -G `grep -oE "wheel|sudo" /etc/group` $user;
        s3=$?;
        if [ "$s3$s2$s1" != "000" ]; then
            fail="$fail $user";
        fi;
    done;
    if [ "$fail" != "" ]; then
        echo "failed to add users $fail";
    else
        echo "Added users"
    fi;

}
