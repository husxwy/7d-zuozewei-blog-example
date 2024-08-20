CREATE USER 'nacos'@'%'IDENTIFIED BY 'nacos@123';
GRANT ALL PRIVILEGES ON `nacos_config_cluster`.* TO 'nacos'@'%' WITH GRANT OPTION;

SHOW GRANTS FOR 'nacos'@'%';