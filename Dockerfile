FROM ubuntu:latest

# Update and install required packages
RUN apt-get update -y > /dev/null 2>&1 && apt-get upgrade -y > /dev/null 2>&1 && apt-get install locales ssh wget unzip -y > /dev/null 2>&1 \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Set the locale environment
ENV LANG en_US.UTF-8

# Set ngrok token as an argument
ARG NGROK_TOKEN
ENV NGROK_TOKEN=${NGROK_TOKEN}

# Download and install ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-amd64.zip > /dev/null 2>&1 \
    && unzip ngrok.zip \
    && mv ngrok /usr/local/bin/ngrok

# Create startup script
RUN echo "#!/bin/bash" > /kaal.sh \
    && echo "ngrok authtoken ${NGROK_TOKEN}" >> /kaal.sh \
    && echo "ngrok tcp --region=in 22 &" >> /kaal.sh \
    && echo "/usr/sbin/sshd -D" >> /kaal.sh

# Set SSH configurations
RUN mkdir /var/run/sshd \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config \
    && echo 'root:kaal' | chpasswd

# Expose ports
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306

# Start the startup script
CMD ["bash", "/kaal.sh"]
