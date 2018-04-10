MANIFEST_NAME=$1
#REMOTE_NAME=$2

if [ "${MANIFEST_NAME}" == "" ]; then
	MANIFEST_NAME=".repo/manifest.xml"
fi

#if [ "${REMOTE_NAME}" == "" ]; then
#	REMOTE_NAME=embux
#fi

if [ ! -e /usr/bin/xmllint ]; then
	echo please install xmllint!
	exit 1
fi

CUR_DIR=$(pwd)

DEFAULT_REV=$(xmllint --xpath "//manifest/default/@revision" ${MANIFEST_NAME} | awk -F "=" '{print $2}' | sed s/\"//g)
DEFAULT_RMT=$(xmllint --xpath "//manifest/default/@remote" ${MANIFEST_NAME} | awk -F "=" '{print $2}' | sed s/\"//g)

PROJ_NUM=$(xmllint --xpath 'count (/manifest/project)' ${MANIFEST_NAME})

for i in $(seq 1 1 ${PROJ_NUM})
do
	PROJ=$(xmllint --xpath "/manifest/project[$i]/@path" ${MANIFEST_NAME} 2>/dev/null | awk -F "=" '{print $2}' | sed s/\"//g)
	REVS=$(xmllint --xpath "/manifest/project[$i]/@revision" ${MANIFEST_NAME} 2>/dev/null | awk -F "=" '{print $2}' | sed s/\"//g)
	if [ "" == "${REVS}" ]; then
		REVS=${DEFAULT_REV}
	fi
	RMTS=$(xmllint --xpath "/manifest/project[$i]/@remote" ${MANIFEST_NAME} 2>/dev/null | awk -F "=" '{print $2}' | sed s/\"//g)
	if [ "" == "${RMTS}" ]; then
		RMTS=${DEFAULT_RMT}
	fi
	##echo ${PROJ} ${REVS}
	echo "($i/${PROJ_NUM})proj: ${PROJ} --> branch: ${RMTS}/${REVS}"
	repo forall ${PROJ} -c git checkout -b ${REVS} remotes/${RMTS}/${REVS} 2>/dev/null
done

cd ${CUR_DIR}
