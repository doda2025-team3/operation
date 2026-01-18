# SETUP VARIABLES
number_of_workers = 2


Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
#   config.vm.box = "bento/ubuntu-24.04"
#   config.vm.box_version = "202510.26.0"

  config.vm.box = "bento/ubuntu-24.04"

  # config.ssh.insert_key = false

  config.vm.define "ctrl" do |ctrl|

    ctrl.vm.hostname = 'ctrl'
    ctrl.vm.box_version = "202510.26.0"
    ctrl.vm.network "private_network", ip: "192.168.56.100"

    ctrl.vm.provider "virtualbox" do |v|
      v.memory = 4096
      v.cpus = 2
    end

    ctrl.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/general.yml"
      ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}  
      ansible.limit = "ctrl"
    end

    ctrl.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/ctrl.yml"
      ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}  
      ansible.limit = "ctrl"
    end

    # ctrl.vm.provision :ansible do |ansible|
    #   ansible.playbook = "ansible/general.yml"
    #   ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}
    #    ansible.inventory_path = "inventory.cfg"
    #   ansible.limit = "ctrl"
    # end

    # ctrl.vm.provision :ansible do |ansible|
    #   ansible.playbook = "ansible/ctrl.yml"
    #   ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}
    #   ansible.inventory_path = "inventory.cfg"
    #   ansible.limit = "ctrl"
    # end

    # config.vm.provision "shell" do |s|
    #   ssh_pub_key = File.readlines("/home/carolyn/Documents/doda2025/dodaProject/operation/ansible/public_keys/key_caro.pub").first.strip
    #   s.inline = <<-SHELL
    #     echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
    #     chmod 600 /home/vagrant/.ssh/authorized_keys
    #     chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
    #   SHELL
    # end

    # ctrl.vm.provision :ansible do |ansible|
    #   ansible.playbook = "ansible/general.yml"
    #   ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}
    #   ansible.inventory_path = "inventory.cfg"
    #   ansible.limit = "all"
    # end

    # ctrl.vm.provision :ansible do |ansible|
    #   ansible.playbook = "ansible/ctrl.yml"
    #   ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}
    #   ansible.inventory_path = "inventory.cfg"
    #   ansible.limit = "ctrl"
    # end

    # ctrl.vm.provision :ansible do |ansible|
    #   ansible.playbook = "ansible/node.yml"
    #   ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}
    #   ansible.inventory_path = "inventory.cfg"
    #   ansible.limit = "node-*"
    # end



  end


  (1..number_of_workers).each do |worker|
    config.vm.define "node-#{worker}" do |node|

      node.vm.hostname = "node-#{worker}"
      # node.vm.box_version = "202510.26.0"
      node.vm.network "private_network", ip: "192.168.56.#{100 + worker}"
      node.vm.provider "virtualbox" do |v|
        v.memory = 6144
        v.cpus = 2
      end

      node.vm.provision "ansible" do |ansible|
        ansible.playbook = "ansible/general.yml"
        ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}  
        ansible.limit = "node-#{worker}"
      end

      node.vm.provision "ansible" do |ansible|
        ansible.playbook = "ansible/node.yml"
        ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}  
        ansible.limit = "node-#{worker}"
      end

      # if worker == number_of_workers
      #   # config.trigger.before :provision do |task|
      #   #   task.name = "Generate inventory.cfg"
      #   #   task.ruby do |_env, _machine|
      #   #     next unless _machine.name.to_s == "node-#{number_of_workers}"

      #   #     # Only active nodes

      #   #     # ssh_cfg = `vagrant ssh-config`
      #   #     # raise "vagrant ssh-config failed" if ssh_cfg.nil? || ssh_cfg.strip.empty?

      #   #     hosts = {}
      #   #     ["ctrl"] + (1..number_of_workers).map { |i| "node-#{i}" }.each do |name|
      #   #       out = `vagrant status #{name}`
      #   #       hosts << name if out.include?("running")
      #   #     end

      #   #     File.open("inventory.cfg", "w") do |file|
      #   #       file.puts "[controller]"
      #   #       if running.include?("ctrl")
      #   #         file.puts "ctrl ansible_host=192.168.56.100 ansible_user=vagrant"
      #   #       end
      #   #       # h = hosts["ctrl"]
      #   #       # raise "ctrl not found" unless h
      #   #       # # file.puts "\nctrl ansible_host=#{hosts["ctrl"]["HostName"]} ansible_user=#{hosts["ctrl"]["User"]} ansible_port=#{hosts["ctrl"]["Port"]} ansible_ssh_private_key_file=#{hosts["ctrl"]["IdentityFile"]}"
      #   #       # file.puts "\nctrl ansible_host=#{h["HostName"]} ansible_user=#{h["User"]} ansible_port=#{h["Port"]}"
              

      #   #       file.puts "\n[nodes]"
      #   #       (1..number_of_workers).each do |node|
      #   #         # file.puts "\n#{node_name} ansible_host=#{h["HostName"]} ansible_user=#{h["User"]} ansible_port=#{h["Port"]} ansible_ssh_private_key_file=#{h["IdentityFile"]}"
      #   #         file.puts "\nnode-#{node} ansible_host=192.168.56.#{100+node} ansible_user=vagrant"
      #   #       end

      #   #       file.puts "\n[all:vars]"
      #   #       file.puts "\nansible_python_interpreter=/usr/bin/python3"
      #   #       file.puts "\nNUM_WORKER_NODES=#{running.grep(/^node-/).length}"
      #   #     end
      #   #   end
      #   # end

      #   node.vm.provision "ansible" do |ansible|
      #     ansible.playbook = "ansible/all_playbooks.yml"
      #     ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}
      #     ansible.inventory_path = "inventory.cfg"
      #     ansible.limit = "all"
      #   end
      # end

      # node.vm.provision :ansible do |ansible|
      #   ansible.playbook = "ansible/node.yml"
      #   ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}
      # end

      # config.vm.provision "shell" do |s|
      #   ssh_pub_key = File.readlines("/home/carolyn/Documents/doda2025/dodaProject/operation/ansible/public_keys/key_caro.pub").first.strip
      #   s.inline = <<-SHELL
      #     echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
      #     chmod 600 /home/vagrant/.ssh/authorized_keys
      #     chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      #   SHELL
      # end

      # node.vm.provision :ansible do |ansible|
      #   ansible.playbook = "ansible/general.yml"
      #   ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}
      #   ansible.inventory_path = "inventory.cfg"
      #   ansible.limit = "node-#{worker}"
      # end 

      # node.vm.provision :ansible do |ansible|
      #   ansible.playbook = "ansible/node.yml"
      #   ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}
      #   ansible.inventory_path = "inventory.cfg"
      #   ansible.limit = "node-#{worker}"
      # end

    end
  end

  #config.trigger.before :provisioning do |task|
  config.trigger.after :up do |task|
    task.name = "Generate inventory.cfg"
    task.ruby do |_env, _machine|
      # next unless _machine.name.to_s == "ctrl"

      nodes = ["ctrl"] + (1..number_of_workers).map { |i| "node-#{i}" }

      running_hosts = []
      nodes.each do |node_name|
        status = `vagrant status #{node_name}`
        running_hosts << node_name if status.include?("running")
      end

      # machine_readable.each_line do |line|
      #   parts = line.strip.split(",", 4)
      #   next unless parts.length >= 4
      #   name, _provider, key, value = parts[1], parts[2], parts[2], parts[3]
      # end

      # machine_readable.each_line do |line|
      #   status = ""
      #   if line.include?("running")
      #     stsus
      #   next unless provider == "state"
      #   states[name] = data
      #   # next unless action == "state" && data == "running"
      #   # running_hosts << name
      # end


      # # nodes = ["ctrl"] + (1..number_of_workers).map { |i| "node-#{i}" }
      # active_nodes = nodes.select { |node| states[node] == "running" }

      # nodes.each do |name|
      #   out = `vagrant status #{name}`
      #   hosts << name if out.include?("running")
      # end

      if running_hosts.empty?
        File.open("inventory.cfg", "w") do |file|
          file.puts "\n[controller]"
          file.puts "\n[nodes]"
          file.puts "\n[all:vars]"
          file.puts "\nansible_python_interpreter=/usr/bin/python3"
          file.puts "\nNUM_WORKER_NODES=0"
        end
        next
      end

      ssh_cfg = `vagrant ssh-config #{running_hosts.join(" ")}`
      raise "vagrant ssh-config failed" if ssh_cfg.nil? || ssh_cfg.strip.empty?

      hosts = {}
      current = nil

      ssh_cfg.each_line do |line|

        line = line.strip

        if line.start_with?("Host ")
          current = line.split(" ", 2)[1]
          hosts[current] = {}
        elsif current && !line.empty?
          key, val = line.split(" ", 2)
          hosts[current][key] = val
        end
      end

      File.open("inventory.cfg", "w") do |file|
        file.puts "[controller]"
        if hosts["ctrl"]
          file.puts "ctrl ansible_host=192.168.56.100 ansible_user=#{hosts["ctrl"]["User"]} ansible_ssh_private_key_file=#{hosts["ctrl"]["IdentityFile"]}"
        end
    
        file.puts "\n[nodes]"
        (1..number_of_workers).each do |node|
          node_name = "node-#{node}"
          next unless hosts[node_name]
          file.puts "\n#{node_name} ansible_host=192.168.56.#{100 + node} ansible_user=#{hosts[node_name]["User"]} ansible_ssh_private_key_file=#{hosts[node_name]["IdentityFile"]}"
          # file.puts "\n#{node_name} ansible_host=#{h["HostName"]} ansible_user=#{h["User"]} ansible_port=#{h["Port"]} ansible_ssh_private_key_file=#{h["IdentityFile"]}"
        end

        file.puts "\n[all:vars]"
        file.puts "\nansible_python_interpreter=/usr/bin/python3"
        file.puts "\nNUM_WORKER_NODES=#{hosts.keys.grep(/^node-\d+$/).length}"
      end
    end
  end

  # config.vm.provision "ansible" do |ansible|
  #   ansible.playbook = "ansible/general.yml"
  #   ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}  
  #   ansible.inventory_path = "inventory.cfg"
  #   ansible.limit = "all"
  # end

  # config.vm.provision "ansible" do |ansible|
  #   ansible.playbook = "ansible/ctrl.yml"
  #   ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}  
  #   ansible.inventory_path = "inventory.cfg"
  #   ansible.limit = "ctrl"
  # end

  # config.vm.provision "ansible" do |ansible|
  #   ansible.playbook = "ansible/node.yml"
  #   ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}  
  #   ansible.inventory_path = "inventory.cfg"
  #   ansible.limit = "node-*"
  # end

  # config.trigger.before :provision do |task|
  #   task.name = "Generate inventory.cfg"
  #   task.ruby do |_env, _machine|

  #     next unless _machine.name.to_s == "ctrl"

  #     # Only active nodes

      # ssh_cfg = `vagrant ssh-config`
      # raise "vagrant ssh-config failed" if ssh_cfg.nil? || ssh_cfg.strip.empty?

      # hosts = {}
      # current = nil

      # ssh_cfg.each_line do |line|

      #   line = line.strip

      #   if line.start_with?("Host ")

      #     current = line.split(" ", 2)[1]
      #     hosts[current] = {}

      #   elsif current

      #     key, val = line.split(" ", 2)
      #     hosts[current][key] = val

      #   end
      # end

  #     File.open("inventory.cfg", "w") do |file|
  #       file.puts "[controller]"
  #       h = hosts["ctrl"]
  #       raise "ctrl not found" unless h
  #       # file.puts "\nctrl ansible_host=#{hosts["ctrl"]["HostName"]} ansible_user=#{hosts["ctrl"]["User"]} ansible_port=#{hosts["ctrl"]["Port"]} ansible_ssh_private_key_file=#{hosts["ctrl"]["IdentityFile"]}"
  #       file.puts "\nctrl ansible_host=#{h["HostName"]} ansible_user=#{h["User"]} ansible_port=#{h["Port"]}"
        

  #       file.puts "\n[nodes]"
  #       hosts.keys.grep(/^node-\d+$/).sort.each do |node_name|
  #         n = hosts[node_name]
  #         # file.puts "\n#{node_name} ansible_host=#{h["HostName"]} ansible_user=#{h["User"]} ansible_port=#{h["Port"]} ansible_ssh_private_key_file=#{h["IdentityFile"]}"
  #         file.puts "\n#{node_name} ansible_host=#{n["HostName"]} ansible_user=#{n["User"]} ansible_port=#{n["Port"]}"
  #       end

  #       file.puts "\n[all:vars]"
  #       file.puts "\nansible_python_interpreter=/usr/bin/python3"
  #       file.puts "\nNUM_WORKER_NODES=#{hosts.keys.grep(/^node-\d+$/).length}"

  #     end
  #   end
  # end

  # config.vm.provision :ansible do |ansible|
  #   ansible.run = "once"
  #   ansible.playbook = "ansible/general.yml"
  #   ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}
  #   ansible.inventory_path = "inventory.cfg"
  #   ansible.limit = "all"
  # end

  # config.vm.provision :ansible do |ansible|
  #   ansible.run = "once"
  #   ansible.playbook = "ansible/ctrl.yml"
  #   ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}
  #   ansible.inventory_path = "inventory.cfg"
  #   ansible.limit = "ctrl"
  # end

  # config.vm.provision :ansible do |ansible|
  #   ansible.run = "once"
  #   ansible.playbook = "ansible/node.yml"
  #   ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}
  #   ansible.inventory_path = "inventory.cfg"
  #   ansible.limit = "node-*"
  # end

  # config.vm.provision "ansible" do |ansible|

  #   # File.open("inventory.cfg", "w") do |file|
  #   #   file.puts "[controller]"
  #   #   file.puts "\nctrl ansible_host=192.168.56.100 ansible_user=vagrant"

  #   #   file.puts "\n[nodes]"
  #   #   (1..number_of_workers).each do |worker|
  #   #     file.puts "\nnode-#{worker} ansible_host=192.168.56.#{100 + worker} ansible_user=vagrant"
  #   #   end

  #   #   file.puts "\n[all:vars]"
  #   #   file.puts "\nansible_python_interpreter=/usr/bin/python3"
  #   #   file.puts "\nNUM_WORKER_NODES=#{number_of_workers}"

  #   # end

  #   ansible.playbook = "ansible/general.yml"
  #   ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}
  #   ansible.inventory_path = "inventory.cfg"
  #   ansible.limit = "all"
  # end

  

  # config.vm.provision "ansible" do |ansible|

  #   # File.open("inventory.cfg", "w") do |file|
  #   #   file.puts "[controller]"
  #   #   file.puts "\nctrl ansible_host=192.168.56.100 ansible_user=vagrant"

  #   #   file.puts "\n[nodes]"
  #   #   (1..number_of_workers).each do |worker|
  #   #     file.puts "\nnode-#{worker} ansible_host=192.168.56.#{100 + worker} ansible_user=vagrant"
  #   #   end

  #   #   file.puts "\n[all:vars]"
  #   #   file.puts "\nansible_python_interpreter=/usr/bin/python3"
  #   #   file.puts "\nNUM_WORKER_NODES=#{number_of_workers}"

  #   # end

  #   ansible.playbook = "ansible/ctrl.yml"
  #   ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}
  #   ansible.limit = "ctrl"
  #   ansible.inventory_path = "inventory.cfg"
  # end

  
  # config.vm.provision "ansible" do |ansible|

  #   # File.open("inventory.cfg", "w") do |file|
  #   #   file.puts "[controller]"
  #   #   file.puts "\nctrl ansible_host=192.168.56.100 ansible_user=vagrant"

  #   #   file.puts "\n[nodes]"
  #   #   (1..number_of_workers).each do |worker|
  #   #     file.puts "\nnode-#{worker} ansible_host=192.168.56.#{100 + worker} ansible_user=vagrant"
  #   #   end

  #   #   file.puts "\n[all:vars]"
  #   #   file.puts "\nansible_python_interpreter=/usr/bin/python3"
  #   #   file.puts "\nNUM_WORKER_NODES=#{number_of_workers}"

  #   # end

  #   ansible.playbook = "ansible/node.yml"
  #   ansible.extra_vars = {"NUM_WORKER_NODES" => number_of_workers}
  #   ansible.inventory_path = "inventory.cfg"
  #   ansible.limit = "node-*"
  # end






  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Disable the default share of the current code directory. Doing this
  # provides improved isolation between the vagrant box and your host
  # by making sure your Vagrantfile isn't accessible to the vagrant box.
  # If you use this you may want to enable additional shared subfolders as
  # shown above.
  # config.vm.synced_folder ".", "/vagrant", disabled: true

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
