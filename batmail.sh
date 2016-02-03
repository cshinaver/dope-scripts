#!/bin/bash
# Messed with by Charles Shinaver
# Bastardization of mailx that works with gmail.
# Make sure to put in your password in order for it to work
# After running, it will expect you to type in the text for the email
# In order to signal end of email, hit ctrl-d

[ ! -z "$FULL_NAME" ] || FULL_NAME="John Cena"
[ ! -z "$EMAIL_ADDRESS" ] || EMAIL_ADDRESS="jcenabuhduhduhduuuuh@nd.edu"
[ ! -z "$PASSWORD" ] || PASSWORD=jlawislife

# Check for password change
if [ "$EMAIL_ADDRESS" == "jcenabuhduhduhduuuuh@nd.edu" ]
then
    echo "Ugh. Come on."
    echo "You are not John Cena. Sorry."
    echo "Open batmail.sh and add your user info at the top"
    exit 1
fi

# Usage
if [ $# == 0 ]
then
    mailx -h 2>&1 | sed 's/mailx/batmail/g' # lol i'm the worst
    echo ""
    echo "Example: ./batmail.sh -s \"Super cool email thing\" -a filetoattach recipient@whatever.com"
    exit 1
fi

# Check if .certs exists
if [ ! -e ~/.certs ]
then
    echo "~/.certs directotry does not exist."
    echo "Creating ~/.certs..."
    mkdir ~/.certs

    # Create new certificate and key database
    certutil -N -d ~/.certs
fi

# Check if gmail cert exists
if ! certutil -L -d ~/.certs | grep Google &>/dev/null
then
    # Create gmail cert
    echo -n | openssl s_client -connect smtp.gmail.com:465 2>/dev/null |
    sed -n '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ~/.certs/gmail.crt
    certutil -A -n 'Google Internet Authority' -t 'C,,' -d ~/.certs -i ~/.certs/gmail.crt
fi

# send mail
mailx -v \
    -S smtp-use-starttls \
    -S ssl-verify=ignore \
    -S smtp-auth=login \
    -S smtp=smtp://smtp.gmail.com:587 \
    -S from="$EMAIL_ADDRESS($FULL_NAME)" \
    -S smtp-auth-user=$EMAIL_ADDRESS \
    -S smtp-auth-password=$PASSWORD \
    -S ssl-verify=ignore \
    -S nss-config-dir=~/.certs \
    $*
