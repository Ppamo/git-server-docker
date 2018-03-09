#!/bin/bash
RED='\e[91m'
GREEN='\e[92m'
BLUE='\e[36m'
YELLOW='\e[93m'
RESET='\e[39m'
IMAGENAME=${IMAGENAME:=git-server-docker}
IMAGEVERSION=${IMAGEVERSION:=0.1.0}
IMAGETAG=${IMAGETAG:=$IMAGENAME:$IMAGEVERSION}

usage(){
	printf $YELLOW"usage:
$BLUE	bash $0 [build|clean|list]
\n"$RESET
}

build(){
	printf $YELLOW"+ building docker image $IMAGETAG\n"$RESET
	docker build -t $IMAGETAG docker/
}

clean(){
	docker images $IMAGETAG --format "{{.Repository}}:{{.Tag}}" | grep $IMAGETAG > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		printf $YELLOW"+ cleaning docker image $IMAGETAG\n"$RESET
		docker rmi $IMAGETAG
		if [ $? -ne 0 ]
		then
			printf -- $RED"- ERROR: couldn't remove image\n"$RESET
			exit -1
		fi
	fi
}

list(){
	printf $YELLOW"+ listing docker images $IMAGETAG\n"$RESET
	docker images $IMAGETAG --format "{{.ID}} - {{.Repository}}:{{.Tag}} - {{printf \"%.20s\" .CreatedAt}}"
}

case $1 in
	build)		build		;;
	clean)		clean		;;
	list)		list		;;
	*)
		usage
		exit 0
esac
