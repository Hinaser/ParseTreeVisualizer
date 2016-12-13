# Setup Memo

## Requirement (Confirmed to work)
Ruby: 2.3.1  
OS: Debian 8 Jessie  
Deps: java, mono, misc apt packages

## Install
1. Install build essentials  
```bash           
sudo apt-get install build-essential libicu-dev libz-dev nodejs libsqlite3-dev zlib1g-dev libmagic-dev libssl-dev openssl git
```

1. Install ruby 2.3.1  
```bash
cd /tmp  
wget https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.1.tar.gz  
tar zxf ruby-2.3.1.tar.gz -C ./  
cd ruby-2.3.1  
./configure --disable-install-rdoc
make
sudo make install  
sudo gem install bundler
```
1. install java  
```bash
sudo apt-get install default-jre
```
1. Install mono  
```bash
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF  
echo "deb http://download.mono-project.com/repo/debian wheezy main" | sudo tee /etc/apt/sources.list.d/mono-xamarin.list  
echo "deb http://download.mono-project.com/repo/debian wheezy-apache24-compat main" | sudo tee -a /etc/apt/sources.list.d/mono-xamarin.list  
echo "deb http://download.mono-project.com/repo/debian wheezy-libjpeg62-compat main" | sudo tee -a /etc/apt/sources.list.d/mono-xamarin.list  
sudo apt-get update
sudo apt-get install mono-complete
```

1. Install this repository  
```bash
cd <wherever-you-want>  
git clone https://github.com/Hinaser/ParseTreeVisualizer.git  
cd ParseTreeVisualizer  
bundle install --path vendor/bundle  
<Setup config/database.yml, config/secret.yml, config/application.yml>
```

1. Install NGINX (Optional)
```bash
sudo apt-get install -y nginx
cd /etc/nginx/sites-enabled
sudo rm -f default
cd ../sites-available
sudo vi ParseTreeVisualizer
<Create nginx config for parse tree visualizer. Sample file is available in this repository under lib/support/nginx/>
sudo ln -s /etc/nginx/sites-available/ParseTreeVisualizer /etc/nginx/sites-enabled/ParseTreeVisualizer 
sudo nginx -t
sudo service nginx restart
```

1. Initial setup
```bash
bundle exec rake antlr4:compile[<grammar name>]
bundle exec rake assets:precompile
```

1. Run
```bash
bundle exec puma -e production -d -b unix://<RAILS ROOT DIR>/tmp/sockets/ParseTreeVisualizer.sock
```

