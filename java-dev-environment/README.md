Creates server development environment for java developer

* available jdks
  * [jdk-5u22-linux-x64.tar.gz](http://sof-tech.pl/jdk/jdk-5u22-linux-x64.tar.gz)
  * [jdk-6u45-linux-x64.tar.gz](http://sof-tech.pl/jdk/jdk-6u45-linux-x64.tar.gz)
  * [jdk-7u80-linux-x64.tar.gz](http://sof-tech.pl/jdk/jdk-7u80-linux-x64.tar.gz)
  * [jdk-8u65-linux-x64.tar.gz](http://sof-tech.pl/jdk/jdk-8u65-linux-x64.tar.gz)
* mysql (starts on boot)
  * all character sets set to ```utf8``` 
  * server 
    * management (```Usage: /etc/init.d/mysql start|stop|restart|reload|force-reload|status```)
      * ```sudo service mysql stop```
      * ```sudo service mysql start```
      * ```sudo service mysql restart```
      * ```sudo service mysql reload```
      * ```sudo service mysql status```
  * client 
    * ```mysql -u root -proot```
* nginx (starts on boot)
  * serves content from ```/home/vagrant/public_html``` 
    * [http://localhost:8080](http://localhost:8080)
    * [https://localhost:4443](https://localhost:4443)
    * [http://192.168.33.10](http://192.168.33.10)
    * [https://192.168.33.10](https://192.168.33.10)
  * management (```Usage: nginx {start|stop|restart|reload|force-reload|status|configtest|rotate|upgrade}```)
    * ```sudo service nginx stop```
    * ```sudo service nginx start```
    * ```sudo service nginx reload```
    * ```sudo service nginx restart```
    * ```sudo service nginx status```
* tomcat 8 (starts on boot) 
  * http://192.168.33.10:8080 (root content)
  * http://192.168.33.10/manager (manager - configuration in nginx)
  * http://192.168.33.10:8080/manager
  * management (```Run as /etc/init.d/tomcat <start|stop|restart>```)
    * sudo service tomcat stop
    * sudo service tomcat start
    * sudo service tomcat restart
* git
* svn
* mc
* vim
* java tools
  * mvn
  * ant
  * gradle
* environment managers
  * [jenv](https://github.com/gcuisinier/jenv.git)
  * [rbenv](https://github.com/sstephenson/rbenv.git)
  * [nodenv](https://github.com/OiNutter/nodenv.git)
  * [pyenv](https://github.com/yyuu/pyenv.git)
* port forwarding 
  * http ```8080 (host) -> 80 (guest)```
  * https ```4443 (host) -> 443 (guest)```
* enabled private network interface (guest -> ```192.168.33.10```)
* current host directory mounted in guest at ```/vagrant```

## connecting to mysql server
```
vagrant@vagrant-ubuntu-vivid-64:~$ mysql -u root -proot
```
## how to use jenv

### Configure which jvm to use

*globally*
```
vagrant@vagrant-ubuntu-vivid-64:~$ jenv global 1.8
```
*locally* (means which jvm to use in the current directory)
```
vagrant@vagrant-ubuntu-vivid-64:~$ jenv local 1.7
```
*shell instance* (which jvm to use in the current shell instance)
```
vagrant@vagrant-ubuntu-vivid-64:~$ jenv shell 1.7
```

*precedence*

1. shell
2. local
3. global

### Configure jvm options

*globally*
```
vagrant@vagrant-ubuntu-vivid-64:~$ jenv global-options "-Xmx512m"
```
*locally*
```
vagrant@vagrant-ubuntu-vivid-64:~$ jenv local-options "-Xmx512m"
```
*shell instance*
```
vagrant@vagrant-ubuntu-vivid-64:~$ jenv shell-options "-Xmx512m"
```

*precedence*

same as for 'Configure which jvm to use'

### Configure gc logging in shell scope

To set gc logging on do
```
vagrant@vagrant-ubuntu-vivid-64:~$ gc_set
```
and
```
vagrant@vagrant-ubuntu-vivid-64:~$ jenv info java
```
will output
```
Jenv will exec : /home/vagrant/.jenv/versions/1.8/bin/java -XX:+PrintGCDetails -Xloggc:gc.log
Exported variables :
  JAVA_HOME=/home/vagrant/.jenv/versions/1.8
```

To unset do
```
vagrant@vagrant-ubuntu-vivid-64:~$ gc_unset
```

### Configure debug options

To set debug options on do
```
vagrant@vagrant-ubuntu-vivid-64:~$ jdebug_set
```
and
```
vagrant@vagrant-ubuntu-vivid-64:~$ jenv info java
```
will output
```
Jenv will exec : /home/vagrant/.jenv/versions/1.8/bin/java -Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=8000,suspend=n
Exported variables :
  JAVA_HOME=/home/vagrant/.jenv/versions/1.8
```
To unset do
```
vagrant@vagrant-ubuntu-vivid-64:~$ jdebug_unset
```

### Configure jrebel

To use jrebel (```jrebel.jar``` must be placed in ```/home/vagrant/bin/jrebel/```) during starting applications do
```
vagrant@vagrant-ubuntu-vivid-64:~$ jrebel_set
```
and
```
vagrant@vagrant-ubuntu-vivid-64:~$ jenv info java
```
will output
```
Jenv will exec : /home/vagrant/.jenv/versions/1.8/bin/java -javaagent:/home/vagrant/bin/jrebel/jrebel.jar -noverify
Exported variables :
  JAVA_HOME=/home/vagrant/.jenv/versions/1.8
```

### Configure jprofiler

To profile application with jprofiler (jprofiler ```agent.jar``` must to be placed in ```/home/vagrant/bin/jprofiler/bin/```) do
```
vagrant@vagrant-ubuntu-vivid-64:~$ jprofiler_set
```
and
```
vagrant@vagrant-ubuntu-vivid-64:~$ jenv info java
```
will output
```
Jenv will exec : /home/vagrant/.jenv/versions/1.8/bin/java -javaagent:/home/vagrant/bin/jprofiler/bin/agent.jar
Exported variables :
  JAVA_HOME=/home/vagrant/.jenv/versions/1.8
```

### Resources
For more information please visit [jenv](https://github.com/gcuisinier/jenv)

## provision.sh trace
```
==> default: Creating directories
==> default:     Creating bin directory
==> default:     Creating public_html directory
==> default:     Creating servers directory
==> default: Installing packages
==> default:     apt-get update
==> default:     Installing vim
==> default:     Installing git
==> default: Installing mc
==> default:     Installing libssl-dev libreadline-dev zlib1g-dev
==> default:     Installing make g++
==> default:     Installing apg
==> default:     Installing mysql-server
==> default:         Creating /etc/mysql/conf.d/utf8_charset.cnf
==> default:         Restarting mysql
==> default:     Installing nginx-core ssl-cert
==> default:         Creating /etc/nginx/sites-available/public_html
==> default:         Enabling /etc/nginx/sites-available/public_html
==> default:         Restarting nginx
==> default: Downloading jdks
==> default:     jdk-5u22-linux-x64.tar.gz is available
==> default:     jdk-6u45-linux-x64.tar.gz is available
==> default:     jdk-7u80-linux-x64.tar.gz is available
==> default:     jdk-8u65-linux-x64.tar.gz is available
==> default: Installing jdks
==> default:     Extracting jdk-5u22-linux-x64.tar.gz
==> default:     Extracting jdk-6u45-linux-x64.tar.gz
==> default: Extracting jdk-7u80-linux-x64.tar.gz
==> default:     Extracting jdk-8u65-linux-x64.tar.gz
==> default:     Cleaning
==> default: Installing apache-maven
==> default:     Downloading apache-maven-3.3.3-bin.tar.gz
==> default:     Extracting apache-maven-3.3.3-bin.tar.gz using tar
==> default:     Cleaning
==> default:     Creating symbolic link apache-maven
==> default: Installing apache-ant
==> default:     Downloading apache-ant-1.9.6-bin.tar.gz
==> default:     Extracting apache-ant-1.9.6-bin.tar.gz using tar
==> default:     Cleaning
==> default:     Creating symbolic link apache-ant
==> default: Installing gradle
==> default:     Downloading gradle-2.8-bin.zip
==> default:     Extracting gradle-2.8-bin.zip using unzip
==> default:     Cleaning
==> default:     Creating symbolic link gradle
==> default: Installing sbt
==> default:     Downloading sbt-0.13.9.tgz
==> default:     Extracting sbt-0.13.9.tgz using tar
==> default:     Cleaning
==> default:     Creating symbolic link sbt
==> default: Installing environment managers (for Java, Ruby, node.js and Python) 
==> default:     Installing jenv
==> default:         Clonning from github to ~/.jenv
==> default:         Setting environment variables
==> default:         Make build tools jenv aware
==> default:             ant plugin activated
==> default:             maven plugin activated
==> default:             gradle plugin activated
==> default:             sbt plugin activated
==> default:     Installing rbenv
==> default:         Clonning from github to ~/.rbenv
==> default:         Installing plugins that provide rbenv install
==> default:     Installing nodenv
==> default:         Clonning from github to ~/.nodenv
==> default:         Installing plugins that provide nodenv install
==> default:     Installing pyenv
==> default:         Clonning from github to ~/.pyenv
==> default: Updating .bashrc
==> default: Install runtimes using environment managers
==> default:     Install java
==> default:     Set jdk 1.8 globally
==> default:     Install ruby
==> default:     Install node.js
==> default:     install python
==> default: Installing apache-tomcat
==> default:     Downloading apache-tomcat-8.0.28.tar.gz
==> default:     Extracting apache-tomcat-8.0.28.tar.gz using tar
==> default:     Cleaning
==> default:     Creating symbolic link apache-tomcat
==> default:     Creating apache-tomcat /bin/setenv.sh
==> default:     Copying tomcat-users.xml to apache-tomcat/conf
==> default:     Creating /etc/init.d/tomcat script
==> default:     Starting tomcat
```
