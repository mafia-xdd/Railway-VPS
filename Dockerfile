# Use the latest Ubuntu image as base
FROM ubuntu:latest

# Update, upgrade, and install necessary locales
RUN apt-get update -y > /dev/null 2>&1 \
    && apt-get upgrade -y > /dev/null 2>&1 \
    && apt-get install -y locales > /dev/null 2>&1 \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Set the default language environment
ENV LANG en_US.UTF-8

# Set ngrok authentication token
ARG NGROK_TOKEN
ENV NGROK_TOKEN=${NGROK_TOKEN}

# Install necessary packages: SSH, wget, unzip
RUN apt-get install ssh wget unzip -y > /dev/null 2>&1

# Download and unzip ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1 \
    && unzip ngrok.zip

# Create startup script for ngrok
RUN echo "./ngrok config add-authtoken ${NGROK_TOKEN} &&" >> /odiyaan.sh \
    && echo "./ngrok tcp --region in 22 &>/dev/null &" >> /odiyaan.sh \
    && mkdir /run/sshd \
    && echo '/usr/sbin/sshd -D' >> /odiyaan.sh \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config \
    && echo 'root:odiyaan' | chpasswd

# Start SSH service and assign permissions to the startup script
RUN service ssh start \
    && chmod 755 /odiyaan.sh

# Expose necessary ports
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306

# Start the ngrok tunneling and SSH services with the startup script
CMD /odiyaan.sh
