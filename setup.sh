#!/bin/bash
RED='\e[91m'
GREEN='\e[92m'
BLUE='\e[36m'
YELLOW='\e[93m'
RESET='\e[39m'
IMAGENAME=${IMAGENAME:=utils/git-server}
IMAGEVERSION=${IMAGEVERSION:=0.1.0}
REGISTRY=${REGISTRY:=localhost}
IMAGETAG=${IMAGETAG:=$REGISTRY/$IMAGENAME:$IMAGEVERSION}
DEPLOYFILE=resources/kubernetes/git_server.de.yaml
PAYLOAD="git_server.pv.yaml git_server.pvc.yaml git_server.se.yaml"

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

deploy(){
	printf $YELLOW"+ deploying to $REGISTRY\n"$RESET
	kubectl create -f $DEPLOYFILE
}

undeploy(){
	printf $YELLOW"+ undeploying from $REGISTRY\n"$RESET
	kubectl delete -f $DEPLOYFILE
}

deploypayload(){
	for RESOURCE in $PAYLOAD
	do
		printf $YELLOW"+ deploying $RESOURCE to $REGISTRY\n"$RESET
		kubectl create -f resources/kubernetes/$RESOURCE
	done
}

undeploypayload(){
	for RESOURCE in $PAYLOAD
	do
		printf $YELLOW"+ undeploying $RESOURCE to $REGISTRY\n"$RESET
		kubectl delete -f resources/kubernetes/$RESOURCE
	done
}

case $1 in
	build)			build			;;
	clean)			clean			;;
	list)			list			;;
	deploy)			deploy			;;
	deploypayload)		deploypayload		;;
	undeploy)		undeploy		;;
	undeploypayload)	undeploypayload		;;
	*)
		usage
		exit 0
esac
