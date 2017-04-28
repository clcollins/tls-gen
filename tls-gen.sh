#!/bin/bash

set -e

usage () {
  echo "usage: mkkey.sh -n HOST_NAME -c CA_NAME"
  echo ""
  echo "If directory CA_NAME exists, cert will be signed by that CA"
  echo "If directory CA_NAME does not exist, a new CA will be created and used"
}

sign () {
  HOST_NAME=${1}
  CA_NAME=${2}

  openssl x509 -req \
          -days 365 \
          -sha256 \
          -in ${HOST_NAME}/${HOST_NAME}.csr \
          -CA ${CA_NAME}/${CA_NAME}.crt \
          -CAkey ${CA_NAME}/${CA_NAME}.key \
          -CAcreateserial -out ${HOST_NAME}/${HOST_NAME}.crt
}

mk_ca () {

  CA_NAME=${1}

  if [[ ! -d $(pwd)/${CA_NAME} ]]
  then
    mkdir $CA_NAME
    openssl genrsa -aes256 \
	    -out ${CA_NAME}/${CA_NAME}.key \
	    4096
    openssl req -new -x509 \
	    -days 365 \
	    -key ${CA_NAME}/${CA_NAME}.key \
	    -out ${CA_NAME}/${CA_NAME}.crt
  else
    echo "Trying to create a CA key for an existing CA! This shouldn't happen!"
    exit 1
  fi
}

mk_csr () {

  HOST_NAME="${1}"

  if [[ ! -d $(pwd)/${HOST_NAME} ]]
  then
    mkdir $HOST_NAME
    openssl genrsa -out ${HOST_NAME}/${HOST_NAME}.key 4096
    openssl req -subj "/CN=${HOST_NAME}" \
                -sha256 \
                -new \
  	        -key ${HOSTDIR}/${HOST_NAME}.key \
  	        -out ${HOSTDIR}/${HOST_NAME}.csr
  fi
}

main () {
  while getopts ":n:c:" opt; do
    case $opt in
      n  ) HOST_NAME=$OPTARG;;
      c  ) CA_NAME=$OPTARG;;
      \? ) usage;;
    esac
  done
  
  if [[ -z $HOST_NAME ]] || [[ -z $CA_NAME ]]
  then
    usage
    exit 1
  fi

  if [[ ! -d $CA_NAME ]]
  then
    mk_ca $CA_NAME
  fi

  mk_csr $HOST_NAME
  sign $HOST_NAME $CA_NAME

}

main "$@"
