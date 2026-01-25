number_of_workers = 2


Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
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
end
