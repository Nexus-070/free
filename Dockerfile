FROM ubuntu:22.04

# မလိုအပ်သောမေးခွန်းများမမေးရန်
ENV DEBIAN_FRONTEND=noninteractive

# လိုအပ်သော package များ (SSH, Curl, Unzip) install လုပ်ခြင်း
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    openssh-server \
    && apt-get clean

# SSH Run ရန် folder ဆောက်ခြင်း
RUN mkdir /var/run/sshd

# Root login ခွင့်ပြုခြင်း
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config

# Ngrok install လုပ်ခြင်း
RUN curl -s https://ngrok-agent-binaries.s3.amazonaws.com/ngrok-v3-stable-linux-amd64.tgz | tar xvz -C /usr/local/bin

# Script ဖိုင်ကို Docker build time တွင် တခါတည်းရေးထည့်ခြင်း
RUN echo '#!/bin/bash\n\
\n\
# 1. Ngrok Token စစ်ဆေးခြင်း\n\
if [ -z "$NGROK_AUTH_TOKEN" ]; then\n\
  echo "Error: NGROK_AUTH_TOKEN is missing!"\n\
  exit 1\n\
fi\n\
\n\
# 2. Password သတ်မှတ်ခြင်း (Railway Env မှယူသည်၊ မရှိလျှင် root ဟုထားမည်)\n\
PASS=${SSH_PASSWORD:-root}\n\
echo "root:$PASS" | chpasswd\n\
\n\
# 3. SSH Service စတင်ခြင်း\n\
service ssh start\n\
\n\
# 4. Ngrok ချိတ်ဆက်ခြင်း\n\
ngrok config add-authtoken $NGROK_AUTH_TOKEN\n\
echo "Starting Ngrok tunnel..."\n\
ngrok tcp 22 --log stdout\n\
' > /start.sh && chmod +x /start.sh

# Container run ချိန်တွင် script ကိုအလုပ်လုပ်ခိုင်းခြင်း
CMD ["/start.sh"]
