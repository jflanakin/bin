#!/bin/bash

ifconfig -a >> /private/tmp/interfaces.txt

sed -n '/bridge0/, /ether/p' /private/tmp/interfaces.txt | sed 's/^.*ether/ether/p' | sed 's/^.*ether/ether/p'
