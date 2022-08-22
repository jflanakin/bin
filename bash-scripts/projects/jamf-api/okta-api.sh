#!/bin/bash

# GLobal Variables
global_token=""
oktaURL=$(cat $(pwd)/okta-token/.oktaURL)

# Gets API token from saved files
getApiToken(){
    # Set local variables
    local secret=$(cat $(pwd)/okta-token/.secret)
    local salt=$(cat $(pwd)/okta-token/.salt)
    local key=$(cat $(pwd)/okta-token/.key)
    local oktaToken=$( echo "${secret}" | openssl enc -aes-256-cbc -md sha512 -a -A -d -S "${salt}" -k "${key}" )
    global_token=$oktaToken
}

# API call to list users
listUsers(){
    curl --location --request GET "$oktaURL/api/v1/users?limit=1" --header 'Accept: application/json' --header 'Content-Type: application/json' --header "Authorization: SSWS ${global_token}" | python -mjson.tool
}

# API call to get a specific user
getUser(){
    local username=""
    read -p "Please enter your username: " username
    curl --location --request GET "$oktaURL/api/v1/users/${username}" --header 'Accept: application/json' --header 'Content-Type: application/json' --header "Authorization: SSWS ${global_token}" | python -mjson.tool
}


