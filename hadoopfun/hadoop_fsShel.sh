#!/bin/bash
#Version : 0.2
#--@auther : Renjith--
# ;-) just for fun
get_user_dir () {
        USER_DIR="/user/$USER"
        CWD=${CWD:-$USER_DIR}
        hadoop fs -stat $USER_DIR > /dev/null
        if [[ $? -ne 0 ]]; then
        CWD="/"
        fi
}

cd_command () {
        if [[ ${1:0:1} == / ]];then
            DIR=$1
                else
            DIR="$CWD/$1"
fi

        hadoop fs -stat $DIR > /dev/null
        if [[ $? -eq 0 ]]; then
        CWD=$DIR

        else
        echo "Error :- unable to run cd command $DIR directory dose not exists"

        fi

}

prompt_cmd () {

echo -n "HADOOP:$CWD-> "
read CMD
}

usage () {
echo '
list : ls <path> or ls .
size : du -s -h <path> or du -s -h .
make directory : mkdir <name>
change directory : cd <dir name>
help : help'

}

run_shell () {

        prompt_cmd

        if [[ ${CMD%% *} == cd ]];then

                if [[ ${CMD:3:4} == .. ]];then


                        CWD=${CWD%/*}

                else

                cd_command ${CMD#* }
                fi

        elif [[ ${CMD%% *} == pwd ]];then

        echo $CWD

        elif [[ ${CMD%% *} == help ]];then

        usage

        elif [[ ${CMD%% *} == exit ]];then

        exit

        else

        PARM="-${CMD%% *}"
        TGT=${CMD##* }
        if [[ ${TGT:0:1} == / ]];then
                EXEC="$PARM ${TGT}"
        elif [[ ${TGT} == 'ls' ]];then

                EXEC="$PARM ${TGT} ${CWD}"
        else
                EXEC="$PARM $CWD/$TGT"
        fi
              hadoop fs $EXEC
        fi
}

echo "Hadoop fs shell Cli version 0.2"
echo ""
usage
echo ""
get_user_dir
while true
do
run_shell
done
