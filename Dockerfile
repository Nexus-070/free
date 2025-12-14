FROM ubuntu:22.04

# မလိုအပ်သောမေးခွန်းများမမေးရန်
ENV DEBIAN_FRONTEND=noninteractive

# SSH Server နှင့် Ngrok install လုပ်ခြင်း
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    openssh-server \
    && apt-get clean

# SSH Run ရန် folder ဆောက်ခြင်း
RUN mkdir /var/run/sshd

# Root login ခွင့်ပြုခြင်း (Password ဖြင့်ဝင်ရန်)
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config

# Ngrok install
RUN curl -s https://ngrok-agent-binaries.s3.amazonaws.com/ngrok-v3-stable-linux-amd64.tgz | tar xvz -C /usr/local/bin

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]