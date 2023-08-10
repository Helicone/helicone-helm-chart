#!/bin/bash

# ##########################
# NGINX Setup
# ##########################

helm install -n kube-system nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx

# ##########################
# TLS Setup
# ##########################

# Create tls dir
mkdir certs
mkdir keys

# Declare arrays for different sets of values
hosts=("worker.localhost" "helicone.localhost" "studio.localhost" "api.localhost")
cert_files=("worker_certificate.pem" "web_certificate.pem" "studio_certificate.pem" "kong_certificate.pem")
key_files=("worker_key.pem" "web_key.pem" "studio_key.pem" "kong_key.pem")

# Iterate through the arrays
for ((i = 0; i < ${#hosts[@]}; i++)); do
  HOST="${hosts[i]}"
  CERT_FILE="${cert_files[i]}"
  KEY_FILE="${key_files[i]}"

  # Run the openssl command
  echo "Running openssl command for ${HOST}:"
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout keys/${KEY_FILE} -out certs/${CERT_FILE} -subj "/CN=${HOST}/O=${HOST}" -addext "subjectAltName = DNS:${HOST}"
  
  # Create the k8s secret
  kubectl create secret tls ${HOST} --key keys/${KEY_FILE} --cert certs/${CERT_FILE}

done

# Remove key files
rm -r keys
