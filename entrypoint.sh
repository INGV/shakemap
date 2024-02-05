#!/bin/bash

set -e 

echo Your container args are: "$@"
echo ""

### START -  Functions
function usage_entrypoint() {
BASE_COMMAND="docker run -it --rm -v \$(pwd)/data/shakemap_profiles:/root/shakemap_profiles -v \$(pwd)/data/shakemap_data:/root/shakemap_data shakemap4 bash"
cat << EOF

 This docker starts shakemap4 software

 usage: 
 $ ${BASE_COMMAND} -p <profile> -c <command>

    Values for option -c: [italy|world]

    Examples:
     1) $ ${BASE_COMMAND} -p italy -c'shake 8863681 select assemble -c "test" model mapping'
     2) $ ${BASE_COMMAND} -p world -c'shake 8863681 select assemble -c "test" model mapping'


EOF
}
### END -  Functions


### START - Check parameters ###
IN__PROFILE=
IN__COMMAND=
while getopts :p:c: OPTION
do
	case ${OPTION} in
	p)	IN__PROFILE="${OPTARG}"
		;;
    c)	IN__COMMAND="${OPTARG}"
		;;
    \?) echo "Invalid option: -$OPTARG" >/dev/null
		shift
		;;
    *)  #echo $OPTARG >/dev/null
		echo "Invalid OPTARG: -$OPTARG" >&2
		;;
	esac
done

# Check input parameter
if [[ -z ${IN__PROFILE} ]]; then
    echo ""
    echo " Please, set the PROFILE param"
    echo ""
    usage_entrypoint
    exit 1
else
    PROFILE=${IN__PROFILE}
fi
if [[ -z ${IN__COMMAND} ]]; then
    echo ""
    echo " Please, set the COMMAND param"
    echo ""
    usage_entrypoint
    exit 1
else
    COMMAND=${IN__COMMAND}
fi 
### END - Check parameters ###





#set -e
#echo "UID=${UID} (from host)"
#echo "GID=${GID} (from host)"
#echo "GROUP_NAME=${GROUP_NAME} (from Dockerfile)"
#echo "USER_NAME=${USER_NAME} (from Dockerfile)"
#if id "${USER_NAME}" &>/dev/null; then
#    echo "Start usermod:"
#    time usermod -u "${UID}" -g ${GID} ${USER_NAME}
#    echo "Done"
#else
#    echo "The user \"${USER_NAME}\" doesn't exist"
#    exit 1
#fi

#echo "Start chown:"
#time chown -R ${UID}:${GID} /home/${USER_NAME} &
#echo "Done"

#whoami

#
#su - ${USER_NAME}

#whoami








# Pull last changes
echo "--->START - GIT commands:<---"
cd /home/shake/gitwork/shakemap_src/

echo "git status:"
git status
echo ""

#echo "git stash:"
#git stash
#echo ""

#echo "git pull:"
#git pull
#echo ""

#echo "git stash pop:"
#git stash pop
#echo ""

echo "git fetch:"
git fetch
echo ""

#echo "git merge 03be81dfdab95bb4562e491ab14d4261b9662e8e:"
#git merge 03be81dfdab95bb4562e491ab14d4261b9662e8e
#echo ""

echo "git status:"
git status
echo ""

echo "--->END - GIT commands:<---"
echo ""

#
echo "-----"
echo "COMMAND: ${COMMAND}"
echo "-----"
echo ""

. /home/shake/miniconda/etc/profile.d/conda.sh \
    && conda activate base \
    && conda info --envs \
    && conda activate shakemap \
    && sm_profile -s ${PROFILE} \
    && eval ${COMMAND}
