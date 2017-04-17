#!/usr/bin/expect -f

spawn ssh -p 2222 ubuntu@localhost
expect "assword:"
send "ubuntu\r"
interact
