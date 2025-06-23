-- ./mysql-init/init.sql
CREATE DATABASE IF NOT EXISTS weatherapp;
CREATE USER 'authuser'@'%' IDENTIFIED BY 'my-secret-pw';
GRANT ALL PRIVILEGES ON weatherapp.* TO 'authuser'@'%';
FLUSH PRIVILEGES;

