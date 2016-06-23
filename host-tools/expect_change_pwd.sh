#!/usr/bin/expect -f
# wrapper to make passwd(1) be non-interactive
# username is passed as 1st arg, passwd as 2nd

spawn sudo passwd
expect "Enter new UNIX password:"
send "222222\r"
expect "Retype new UNIX password: "
send "222222\r"
expect eof
