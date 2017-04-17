#!/bin/bash

# make sure project argument is given
if [ $# -lt 1 ]; then
    echo "Usage: provision.sh <project>"
    exit 0
fi

PROJECT=$1

# install packages
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    curl \
    exuberant-ctags \
    git \
    httpie \
    libbz2-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    llvm \
    make \
    nginx \
    ruby \
    ruby-dev \
    vim-nox \
    wget \
    xz-utils \
    zlib1g-dev

# configure nginx
sudo rm /etc/nginx/sites-enabled/default > /dev/null 2>&1
sudo service nginx reload

# install vimrc
if [ ! -d ~/.vim ] ; then
    mkdir ~/.vim
    git clone git://github.com/tmacwill/vimrc.git ~/.vim
    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    ln -s ~/.vim/.vimrc ~/.vimrc
    vim +BundleInstall +qall
    pushd ~/.vim/bundle/Command-T/ruby/command-t
    ruby extconf.rb
    make
    popd
fi

# install and configure pyenv
if ! type "pyenv" > /dev/null 2>&1 ; then
    curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
    echo "" >> ~/.bashrc
    echo 'export PATH="~/.pyenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
    echo 'pyenv shell 3.6.0' >> ~/.bashrc
    export PATH="~/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
    pyenv install 3.6.0
    pyenv shell 3.6.0
    pip install virtualenv
fi

# install postgres
if ! type "psql" > /dev/null 2>&1 ; then
    sudo add-apt-repository --remove "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /dev/null 2>&1
    sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main"
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    sudo apt-get update
    sudo apt-get install -y postgresql-server-dev-9.6 postgresql-9.6 postgresql-client-9.6 postgresql-contrib-9.6
fi

# install nodejs
if ! type "node" > /dev/null 2>&1 ; then
    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# create project directory
mkdir ~/$PROJECT
cd ~/$PROJECT

# create postgres user and database
sudo -u postgres psql -c "create user $PROJECT with password '$PROJECT' superuser login createrole createdb"
sudo -u postgres createdb $PROJECT

# install pip packages
virtualenv venv
. ./venv/bin/activate
pip install \
    ipython \
    peewee \
    psycopg2 \
    requests \
    sanic \
    watchdog

# install npm packages, using separate lines because big install causes some crazy filesystem error?
npm install "babel-loader"
npm install "babel-core"
npm install "babel-preset-react"
npm install "babel-preset-es2015"
npm install "babel-preset-stage-2"
npm install "css-loader"
npm install "extract-text-webpack-plugin"
npm install "less"
npm install "less-loader"
npm install "node-sass"
npm install "react"
npm install "react-dom"
npm install "sass-loader"
npm install "style-loader"
npm install "webpack"
