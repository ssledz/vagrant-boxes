#!/bin/bash

VAGRANT_DIR=/vagrant
HOME_DIR=~/
HOME_SERVERS_DIR=$HOME_DIR/servers
HOME_PUBLIC_HTML_DIR=$HOME_DIR/public_html
HOME_BIN_DIR=$HOME_DIR/bin

installPackage()
{
  local packages=$*
  echo "Installing $packages"
  sudo apt-get install -y $packages >/dev/null 2>&1
}

indent() 
{
  echo -n '    '
}

downloadWithProgress()
{
  local url=$2
  local file=$1
  echo -n "Downloading $file:"
  echo -n "    "
  wget --progress=dot $url 2>&1 | grep --line-buffered "%" | sed -u -e 's/\.//g' | awk '{printf("\b\b\b\b%4s", $2)}'
  echo -ne "\b\b\b\b"
  echo " DONE"
}

download()
{
  local url=$2
  local file=$1
  echo "Downloading $file"
  wget --progress=dot $url >/dev/null 2>&1
}

installMysql() 
{
  #setting non-interactive mode
  echo mysql-server mysql-server/root_password password root | sudo debconf-set-selections
  echo mysql-server mysql-server/root_password_again password root | sudo debconf-set-selections
  indent; installPackage mysql-server
  indent; indent; echo 'Creating /etc/mysql/conf.d/utf8_charset.cnf'
  sudo cp $VAGRANT_DIR/mysql/utf8_charset.cnf /etc/mysql/conf.d/utf8_charset.cnf
  indent; indent; echo 'Restarting mysql'
  sudo service mysql restart >/dev/null 2>&1
}

installNginx() 
{
  indent; installPackage nginx-core ssl-cert
  indent; indent; echo 'Creating /etc/nginx/sites-available/public_html'
  sudo cp $VAGRANT_DIR/nginx/public_html /etc/nginx/sites-available/public_html
  sudo rm /etc/nginx/sites-enabled/default
  indent; indent; echo 'Enabling /etc/nginx/sites-available/public_html'
  sudo ln -s /etc/nginx/sites-available/public_html /etc/nginx/sites-enabled/public_html
  indent; indent; echo 'Restarting nginx'
  cp /var/www/html/index.nginx-debian.html $HOME_PUBLIC_HTML_DIR
  sudo service nginx restart
}

installPackages()
{
  echo "Installing packages"
  indent; echo 'apt-get update'
  sudo apt-get update >/dev/null 2>&1
  indent; installPackage vim
  indent; installPackage git
  indent; installPackage mc
  #dependencies for pyenv
  indent; installPackage make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev
  #dependencies for rbenv
  indent; installPackage autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev
  indent; installPackage apg
  installMysql
  installNginx
}

createDirs()
{
  echo 'Creating directories'
  indent; echo 'Creating bin directory'
  mkdir $HOME_BIN_DIR
  indent; echo 'Creating public_html directory'
  mkdir $HOME_PUBLIC_HTML_DIR
  chmod o+xr $HOME_PUBLIC_HTML_DIR
  mkdir $HOME_SERVERS_DIR
  indent; echo 'Creating servers directory'
}

downloadJdks()
{
  echo "Downloading jdks"
  for jdk in jdk-5u22-linux-x64.tar.gz jdk-6u45-linux-x64.tar.gz jdk-7u80-linux-x64.tar.gz jdk-8u65-linux-x64.tar.gz 
  do 
    if [ ! -e $jdk ] 
    then 
      indent; echo "There is no $jdk"
      indent; indent; download "$jdk" "http://sof-tech.pl/jdk/$jdk"
    else 
      indent; echo "$jdk is available"
    fi 
  done
}

installJdks()
{
  echo 'Installing jdks'
  for file in `ls jdk*.tar.gz`
  do 
    indent; echo "Extracting $file"
    tar xvzf ./$file >/dev/null 2>&1
  done
  indent; echo 'Cleaning'
  rm jdk*.tar.gz
}

installEnvManagers()
{
  echo 'Installing environment managers (for Java, Ruby, node.js and Python) '
  indent; echo 'Installing jenv'
  indent; indent; echo 'Clonning from github to ~/.jenv'
  git clone https://github.com/gcuisinier/jenv.git ~/.jenv >/dev/null 2>&1
  indent; indent; echo "Setting environment variables"
  export PATH="$HOME/.jenv/bin:$PATH"
  eval "$(jenv init -)"
  indent; indent; echo 'Make build tools jenv aware'
  message=`jenv enable-plugin ant`
  indent; indent; indent; echo $message
  message=`jenv enable-plugin maven`
  indent; indent; indent; echo $message
  message=`jenv enable-plugin gradle`
  indent; indent; indent; echo $message
  message=`jenv enable-plugin sbt`
  indent; indent; indent; echo $message

  indent; echo 'Installing rbenv'
  indent; indent; echo 'Clonning from github to ~/.rbenv'
  git clone https://github.com/sstephenson/rbenv.git ~/.rbenv >/dev/null 2>&1
  indent; indent; echo 'Installing plugins that provide rbenv install'
  git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build >/dev/null 2>&1

  indent; echo 'Installing nodenv'
  indent; indent; echo 'Clonning from github to ~/.nodenv'
  git clone https://github.com/OiNutter/nodenv.git ~/.nodenv >/dev/null 2>&1
  indent; indent; echo 'Installing plugins that provide nodenv install'
  git clone https://github.com/OiNutter/node-build.git ~/.nodenv/plugins/node-build >/dev/null 2>&1
  indent; indent; echo "Setting environment variables"
  export PATH="$HOME/.nodenv/bin:$PATH"
  eval "$(nodenv init -)"

  indent; echo 'Installing pyenv'
  indent; indent; echo 'Clonning from github to ~/.pyenv'
  git clone https://github.com/yyuu/pyenv.git ~/.pyenv >/dev/null 2>&1
}

updateBashrc()
{
  echo 'Updating .bashrc'
  cat $VAGRANT_DIR/bashrc.template >> $HOME_DIR/.bashrc
  source $HOME_DIR/.bashrc
}


installRuntimes()
{
  echo 'Install runtimes using environment managers'
  indent; echo 'Install java'
  for jdk in `ls $HOME_BIN_DIR/ | grep jdk`; do jenv add $HOME_BIN_DIR/$jdk >/dev/null 2>&1; done
  indent; echo 'Set jdk 1.8 globally'
  jenv global 1.8

  indent; echo 'Install ruby'
  #time consuming operation
  #rbenv install 1.9.3-p0

  indent; echo 'Install node.js'
  nodenv install 4.2.1 >/dev/null 2>&1
  nodenv global 4.2.1

  indent; echo 'install python'
  #time consuming operation
  #pyenv install 3.5.0

}


installingApp()
{
  local tool_name=$1
  local file=$2
  local url=$3
  local link_src=$4
  local link_target=$5
  echo "Installing $tool_name"
  indent; download $file $url
  indent; echo -n "Extracting $file"
  if [[ "$file" =~ .*tar.gz$ || "$file" =~ .*tgz$ ]]
  then 
    echo " using tar"
    tar xvzf $file >/dev/null 2>&1
  else
    if [[ "$file" =~ .*zip$ ]]
    then
      echo " using unzip"
      unzip $file >/dev/null 2>&1
    else
      echo
      indent; indent; echo "Can't extract $file. Unknown ext"
    fi
  fi
  indent; echo 'Cleaning'
  rm $file
  indent; echo "Creating symbolic link $link_target"
  ln -s $link_src $link_target
}

installingMvn()
{
  installingApp 'apache-maven' \
    apache-maven-3.3.3-bin.tar.gz \
    http://www.eu.apache.org/dist/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz \
    'apache-maven*' \
    apache-maven
}

installingAnt()
{
  installingApp 'apache-ant' \
    apache-ant-1.9.6-bin.tar.gz \
    http://www.eu.apache.org/dist/ant/binaries/apache-ant-1.9.6-bin.tar.gz \
    'apache-ant*' \
    apache-ant
}

installingGradle()
{
  installingApp 'gradle' \
    gradle-2.8-bin.zip \
    https://services.gradle.org/distributions/gradle-2.8-bin.zip \
    'gradle-*' \
    gradle
}

installingSbt()
{
  installingApp 'sbt' \
    sbt-0.13.9.tgz \
    https://dl.bintray.com/sbt/native-packages/sbt/0.13.9/sbt-0.13.9.tgz \
    'sbt' \
    sbt
}

installingTools() 
{
  cd $HOME_BIN_DIR
  installingMvn
  installingAnt
  installingGradle
  installingSbt
}

installingTomcat()
{
  installingApp 'apache-tomcat' \
    apache-tomcat-8.0.28.tar.gz \
    http://ftp.piotrkosoft.net/pub/mirrors/ftp.apache.org/tomcat/tomcat-8/v8.0.28/bin/apache-tomcat-8.0.28.tar.gz \
    'apache-tomcat*' \
    apache-tomcat

  indent; echo 'Creating apache-tomcat /bin/setenv.sh'
  echo 'JAVA_HOME=`jenv javahome`' > apache-tomcat/bin/setenv.sh
  chmod +x apache-tomcat/bin/setenv.sh
  indent; echo 'Copying tomcat-users.xml to apache-tomcat/conf'
  cp $VAGRANT_DIR/tomcat/tomcat-users.xml apache-tomcat/conf
  indent; echo 'Creating /etc/init.d/tomcat script'
  sudo cp $VAGRANT_DIR/tomcat/tomcat /etc/init.d/
  sudo chmod 755 /etc/init.d/tomcat
  sudo update-rc.d tomcat defaults
  sudo update-rc.d tomcat enable
  indent; echo 'Starting tomcat'
  sudo service tomcat start
}

installingServers()
{
  cd $HOME_SERVERS_DIR
  installingTomcat
}

run() {
  createDirs
  installPackages
  cd $VAGRANT_DIR
  downloadJdks
  echo "Copying jdks to $HOME_BIN_DIR" >/dev/null 2>&1
  cp -r $VAGRANT_DIR/jdk*.tar.gz $HOME_BIN_DIR
  cd $HOME_BIN_DIR  
  installJdks
  installingTools
  installEnvManagers
  updateBashrc
  installRuntimes
  installingServers
}


if [ ! -f "/var/vagrant_provision" ]; then
  sudo touch /var/vagrant_provision
  run
else
  echo "Nothing to do"
fi




