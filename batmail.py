# batmail.py
# Created by Charles Shinaver

import argparse
import os
from subprocess import call

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='')
    parser.add_argument(
        'recipient_address',
        help='email address of recipient',
    )
    parser.add_argument(
        '-a', type=str,
        required=False,
        help='attachment file',
    )
    args = parser.parse_args()

    # Check if .certs exists
    certs_exists = os.path.exists(os.path.join(os.environ['HOME'], ".certs"))
    if not certs_exists:
        print "    ~/.certs directory does not exist."
        print "    Please run the command below to create the .certs directory."
        print "    $   mkdir ~/.certs && certutil -N -d ~/.certs"
        exit(1)

    # Get gmail certificate
    gmail_cert_exists = os.path.exists(os.path.join(os.environ['HOME'], ".certs/gmail.crt"))
    if not gmail_cert_exists:
        print "    Creating gmail certificate..."
        call(
            "echo -n | openssl s_client -connect smtp.gmail.com:465 | sed -ne"
            "'/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ~/.certs/gmail.crt",
            shell=True
        )
    print call(
        'certutil -A -n "Google Internet Authority" -t "C,," -d ~/.certs'
        '-i ~/.certs/gmail.crt',
        shell=True,
    )
