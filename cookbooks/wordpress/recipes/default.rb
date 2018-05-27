#
# Cookbook:: wordpress
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.



apt_update 'update' 


# instalacion apache2
package %w(apache2 libapache2-mod-php7.0) do
  action :install
end


# instalacion paquetes de PHP
package %w(php7.0 php7.0-mysql php-curl php-gd php-mbstring php-mcrypt php-xml php-xmlrpc) do
  action :install
end 
service "apache2" do
  action [:enable, :start]
end

# instalacion msql
package 'mysql-server-5.7' do
  action :install
end 

package %w(mysql-common python-mysqldb) do
  action :install
end 


template '/home/vagrant/.my.cnf' do
 source 'my.cnf.erb'
variables ({
:clave => node['main']['mysqlpass']
})
end

# Fin lamp

# crear directorio serverweb

directory '/var/www/wordpress' do
action :create
end

cookbook_file '/etc/apache2/sites-available/wordpress.conf' do
source 'web.conf'
action :create
end

link '/etc/apache2/sites-enabled/wordpress.conf' do
to '/etc/apache2/sites-available/wordpress.conf'
target_file '/etc/apache2/sites-enabled/wordpress.conf'
action :create
end

ruby_block "modificar fichero host" do
  block do
    fe = Chef::Util::FileEdit.new('/etc/hosts')
    fe.insert_line_if_no_match("192.168.33.10	wordpress.local","192.168.33.10	wordpress.local")
    fe.write_file
  end  
end

ruby_block "modificar fichero ports" do
  block do
    fe = Chef::Util::FileEdit.new('/etc/apache2/ports.conf')
    fe.insert_line_if_no_match("Listen	8080","Listen	8080")
    fe.write_file
  end  
end

service 'apache2' do
	action :restart
end

# fin serverweb

####################
# wordpress INICIO
####################

#descargar y descomprimir apliacacion

apt_update 'update' 

execute 'descarga' do
command 'wget http://wordpress.org/latest.tar.gz -O /home/vagrant/wp.tar.gz'
cwd '/home/vagrant/'
creates '/home/vagrant/wp.tar.gz'
not_if { ::File.exists? '/home/vagrant/wp.tar.gz' }

end

execute 'descompresion' do
command 'tar zxvf /home/vagrant/wp.tar.gz -C /home/vagrant/'
not_if { ::File.exists? '/home/vagrant/wordpress/index.php' }
end


# descarga y descomprension finalizada
# Configuracion aplicacion 

execute 'duplicar fichero configuracion' do
command 'cp /home/vagrant/wordpress/wp-config-sample.php /home/vagrant/wordpress/wp-config.php'
#not_if { ::File.exists? '/home/vagrant/wordpress/wp-config.php' }
end

ruby_block 'modificar fichero configuracion' do
  block do
    rc = Chef::Util::FileEdit.new('/home/vagrant/wordpress/wp-config.php')
    rc.search_file_replace_line("DB_NAME","define('DB_NAME', '#{node['main']['nombredb']}');")
	rc.search_file_replace_line("DB_USER","define('DB_USER', '#{node['main']['userdb']}');")
	rc.search_file_replace_line("DB_PASSWORD","define('DB_PASSWORD', '#{node['main']['passuserdb']}');")
    rc.write_file
  end
end

execute 'copiar la aplicacion al servidor web' do
command 'cp -a /home/vagrant/wordpress/. /var/www/wordpress/'
not_if { ::File.exists? '/var/www/wordpress/index.php' }
end

execute 'Creamos la BBDD de wordpress' do
command "mysql -e \"CREATE DATABASE IF NOT EXISTS #{node['main']['nombredb']} DEFAULT CHARACTER SET UTF8;\""

end

execute ' creamos usuario de BBDD para wordpress ' do
command "mysql -e \"GRANT ALL PRIVILEGES ON #{node['main']['nombredb']}.* TO '#{node['main']['userdb']}'@'localhost' IDENTIFIED BY '#{node['main']['passuserdb']}';\""
end


####################
# Wordpress final
####################
