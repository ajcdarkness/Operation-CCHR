QUIET (){
    eval $@ 2>/dev/null >/dev/null
    return $?
}
