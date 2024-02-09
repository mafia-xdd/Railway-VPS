# Set the base image to the latest version of Ubuntu
FROM ubuntu:latest

# Update the package lists, upgrade installed packages to the latest version, and install locales
RUN apt update -y > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1 && apt install locales -y \
&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Set the default locale to en_US.utf8
ENV LANG en_US.utf8

# Define an argument NGROK_TOKEN and set it as an environment variable
ARG NGROK_TOKEN
ENV NGROK_TOKEN=${NGROK_TOKEN}

# Install SSH, wget, and unzip
RUN apt install ssh wget unzip -y > /dev/null 2>&1

# Download ngrok binary
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1

# Unzip ngrok binary
RUN unzip ngrok.zip

# Add ngrok authentication token to the run script
RUN echo "./ngrok config add-authtoken ${NGROK_TOKEN} &&" >>/odiyaan.sh

# Start an SSH tunnel using ngrok on port 22
RUN echo "./ngrok tcp --region in 22 &>/dev/null &" >>/odiyaan.sh

# Create a directory for sshd to run
RUN mkdir /run/sshd

# Add the command to start the SSH daemon to the run script
RUN echo '/usr/sbin/sshd -D' >>/odiyaan.sh

# Enable root login and password authentication in sshd configuration
RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Set the password for the root user
RUN echo root:odiyaan|chpasswd

# Start the SSH service
RUN service ssh start

# Give execute permissions to the run script
RUN chmod 755 /odiyaan.sh

# Expose necessary ports
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306

# Run the run script when the container starts
CMD  /odiyaan.sh
