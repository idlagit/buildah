# Use a base image
FROM centos:7

# Install Apache web server
RUN yum install -y httpd

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["httpd", "-D", "FOREGROUND"]
