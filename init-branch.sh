MANIFEST_NAME=$1
REMOTE_NAME=$2

if [ ! -e ${MANIFEST_NAME} ]; then
	echo the manifest file is not exist!
	exit 2
fi

if [ "${REMOTE_NAME}" == "" ]; then
	REMOTE_NAME=embux
fi

if [ ! -e /usr/bin/xmllint ]; then
	echo please install xmllint!
	exit 1
fi

CUR_DIR=$(pwd)

DEFAULT_REV=$(xmllint --xpath "//manifest/default/@revision" ${MANIFEST_NAME} | awk -F "=" '{print $2}' | sed s/\"//g)

PROJ_NUM=$(xmllint --xpath 'count (/manifest/project)' ${MANIFEST_NAME})

for i in $(seq 1 1 ${PROJ_NUM})
do
	PROJ=$(xmllint --xpath "/manifest/project[$i]/@path" ${MANIFEST_NAME} 2>/dev/null | awk -F "=" '{print $2}' | sed s/\"//g)
	REVS=$(xmllint --xpath "/manifest/project[$i]/@revision" ${MANIFEST_NAME} 2>/dev/null | awk -F "=" '{print $2}' | sed s/\"//g)
	if [ "" == "${REVS}" ]; then
		REVS=${DEFAULT_REV}
	fi
	##echo ${PROJ} ${REVS}
	echo "($i/${PROJ_NUM})proj: ${PROJ} --> branch: ${REVS}"
	repo forall ${PROJ} -c git checkout -b ${REVS} remotes/${REMOTE_NAME}/${REVS} 2>/dev/null
done

cd ${CUR_DIR}
