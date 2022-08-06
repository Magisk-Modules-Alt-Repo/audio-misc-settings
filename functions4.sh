#!/system/bin/sh

function toHexString()
{
    if [ $# -ge 1 ]; then
        local tmp
        tmp=`echo -n "$1" | xxd -p | tr -d ' \n'`
        if [ $# -eq 2 ]; then
            if [ ${#tmp} -ge $2 ]; then
                echo -n ${tmp:0:$2}
            else
                local strt=`expr ${#tmp} + 1`
                echo -n "$tmp"
                for i in `seq $strt $2` ; do
                    echo -n "0"
                done
            fi
        else
            echo -n "$tmp"
        fi
    else
      return 1
    fi
}

# Patch libalsautils.so to map a property string to another
#   arg1: original libalsautils.so file;  arg2: patched libalsautils.so file; 
function patchMapProperty()
{
    local orig_prop='ro.audio.usb.period_us'
    local new_prop='vendor.audio.usb.perio'
    
    if [ $# -eq 2  -a  -r "$1" ]; then
      local pat1=`toHexString "$orig_prop"`
      local pat2=`toHexString "$new_prop" ${#pat1}`
      
      xxd -p <"$1" | tr -d ' \n' | sed -e "s/$pat1/$pat2/" \
          | awk 'BEGIN {
                 foldWidth=60
                 getline buf
                 len=length(buf)
                 for (i=1; i <= len; i+=foldWidth) {
                     if (i + foldWidth - 1 <= len)
                         print substr(buf, i, foldWidth)
                     else
                         print substr(buf, i, len)
                 }
                 exit
             }'  \
         | xxd -r -p >"$2"
      return $?
    else
      return 1
    fi
}
