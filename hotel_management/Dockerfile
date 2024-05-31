# Use the centos:centos7 base image
FROM ubuntu:22.04

# Set the working directory inside the container
WORKDIR /app
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update -y
RUN apt install apache2 php libapache2-mod-php php-mysql mysql-client -y

# Copy all files from the current directory into the container's /app directory
COPY . .

RUN chmod +x /app/setup.sh

RUN rm -f /var/www/html/index.html
RUN cp -r /app/* /var/www/html/

EXPOSE 80
# Command to run when the container starts
CMD ["/app/setup.sh"]