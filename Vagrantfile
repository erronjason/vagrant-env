# -*- mode: ruby -*-
# vi: set ft=ruby :


if !Vagrant.has_plugin?('vagrant-reload') &&  ENV['SKIP'] != 'true'
    if RUBY_PLATFORM =~ /win/ && RUBY_PLATFORM !~ /darwin/
      puts "The vagrant-reload plugin is required. Please install it with \"vagrant plugin install vagrant-reload\""
      exit
    end

    print "Installing vagrant plugin vagrant-reload..."
    %x(bash -c "export SKIP=true; vagrant plugin install vagrant-reload") unless Vagrant.has_plugin?('vagrant-reload') || ENV['SKIP'] == 'true'
    puts "Done!"
    puts "Please re-run your vagrant command..."
    exit
end


Vagrant.configure("2") do |config|

    config.vm.box = "scotch/box"
    config.vm.network "private_network", ip: "192.168.33.2"
    config.vm.hostname = "server"
    config.vm.provision :shell, path: "scripts/bootstrap.sh"
    config.vm.provision :reload
    config.vm.synced_folder "public_html/", "/var/www/public_html",
      owner: "vagrant", group: "vagrant", :mount_options => ["dmode=777", "fmode=666"]


    config.vm.synced_folder "scripts/root", "/root"

    #Box physical limits
    config.vm.provider "virtualbox" do |vm|
        vm.memory = 2048
        vm.cpus = 2
        vm.customize ["modifyvm", :id, "--cpuexecutioncap", "90"]
    end

end
