#!/bin/bash

tmux \
    new-session  "ping 192.168.1.1 | cut -d' ' -f4,7-9 ; read" \; \
    split-window "ping 192.168.1.2 | cut -d' ' -f4,7-9 ; read" \; \
    split-window "ping 192.168.1.254 | cut -d' ' -f4,7-9 ; read" \; \
    split-window "ping 8.8.8.8 | cut -d' ' -f4,7-9 ; read" \; \
    select-layout even-vertical
