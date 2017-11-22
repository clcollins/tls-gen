#!/usr/bin/env bash

set -o errexit

usage () {
  echo "usage: tls-gen.sh -n HOST_NAME -c CA_NAME"
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
          -in ${CA_NAME}/${HOST_NAME}/${HOST_NAME}.csr \
          -CA ${CA_NAME}/${CA_NAME}.crt \
          -CAkey ${CA_NAME}/${CA_NAME}.key \
          -CAcreateserial -out ${CA_NAME}/${HOST_NAME}/${HOST_NAME}.crt
}

mk_ca () {

  CA_NAME=${1}

  if [[ ! -d $(pwd)/${CA_NAME} ]]
  then
    mkdir $CA_NAME
    openssl req \
      -new \
      -x509 \
      -nodes \
	    -days 3650 \
      -newkey rsa:4096 \
	    -keyout ${CA_NAME}/${CA_NAME}.key \
	    -out ${CA_NAME}/${CA_NAME}.crt
  else
    echo "Trying to create a CA key for an existing CA! This shouldn't happen!"
    exit 1
  fi
}

mk_csr () {

  HOST_NAME="${1}"
  CA_NAME="${2}"

  if [[ ! -d $(pwd)/${CA_NAME}/${HOST_NAME} ]]
  then
    mkdir ${CA_NAME}/$HOST_NAME
  else
    echo "$(pwd)/${CA_NAME}/${HOST_NAME} already exists"
  fi
  openssl genrsa -out ${CA_NAME}/${HOST_NAME}/${HOST_NAME}.key 4096
  openssl req -subj "/CN=${HOST_NAME}" \
              -sha256 \
              -new \
          -key ${CA_NAME}/${HOST_NAME}/${HOST_NAME}.key \
          -out ${CA_NAME}/${HOST_NAME}/${HOST_NAME}.csr
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
    echo "Creating CA: $CA_NAME"
    mk_ca $CA_NAME
  fi

  echo "Creating CSR for Host: $HOST_NAME"
  mk_csr $HOST_NAME $CA_NAME

  echo "Signing CRT for Host $HOST_NAME using CA $CA_NAME"
  sign $HOST_NAME $CA_NAME

}

main "$@"
