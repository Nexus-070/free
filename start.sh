#!/bin/bash

# SSH Password သတ်မှတ်ခြင်း (Railway Variable မှယူမည်)
if [ -z "$SSH_PASSWORD" ]; then
  echo "SSH_PASSWORD not set. Using default: 'root'"
  export SSH_PASSWORD="root"
fi

# Root password ပြောင်းခြင်း
echo "root:$SSH_PASSWORD" | chpasswd

# Ngrok Auth
if [ -z "$NGROK_AUTH_TOKEN" ]; then
  echo "Error: NGROK_AUTH_TOKEN is missing!"
  exit 1
fi

ngrok config add-authtoken $NGROK_AUTH_TOKEN

# SSH Service စခြင်း
service ssh start

# Ngrok TCP tunnel ဖွင့်ခြင်း (SSH Port 22 ကို forward လုပ်မည်)
echo "Starting Ngrok tunnel for SSH..."
ngrok tcp 22 --log stdout