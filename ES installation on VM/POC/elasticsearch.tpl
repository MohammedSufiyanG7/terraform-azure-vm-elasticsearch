#cloud-config

packages:
  - curl

write_files:
  - path: /esinstallation.sh
    permissions: "0777"
    content: |
      #!/bin/bash
      sudo apt-get update -y && sudo apt-get upgrade -y
      echo "Installing the apt-transport-https package to access repository over HTTPS"
      sudo apt install apt-transport-https
      echo "Installing the OpenJDK 11 on Ubuntu"
      sudo apt install openjdk-11-jdk -y
      echo "Downloading and Installing Elasticsearch v8.3.3 (Debian packages)"
      wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.3.3-amd64.deb
      wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.3.3-amd64.deb.sha512
      shasum -a 512 -c elasticsearch-8.3.3-amd64.deb.sha512
      sudo DEBIAN_FRONTEND=noninteractive dpkg -i elasticsearch-8.3.3-amd64.deb > elasticsearchjpkg.txt

      sudo mkdir /etc/es
      sudo cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.backup 

      # Edit the yaml file of all vms
      cat > elasticsearch.sh << EOF

      #!/bin/bash
      sudo cat > /etc/elasticsearch/elasticsearch.yml << 'EOF'
      # ======================== Elasticsearch Configuration =========================
      
      # NOTE: Elasticsearch comes with reasonable defaults for most settings.
      #       Before you set out to tweak and tune the configuration, make sure you
      #       understand what you are trying to accomplish and the consequences.
      
      # The primary way of configuring a node is via this file. This template lists
      # the most important settings you may want to configure for a production cluster.
      
      # Please consult the documentation for further information on configuration options:
      # https://www.elastic.co/guide/en/elasticsearch/reference/index.html
      
      # ---------------------------------- Cluster -----------------------------------
      
      # Use a descriptive name for your cluster:
      cluster.name: master-platform
      
      # ------------------------------------ Node ------------------------------------
      
      # Use a descriptive name for the node:
      node.name: master-node-1
      
      # Add custom attributes to the node:
      # node.attr.rack: r1
      
      # ----------------------------------- Paths ------------------------------------
      
      # Path to directory where to store the data (separate multiple locations by comma):
      path.data: /var/lib/elasticsearch
      
      # Path to log files:
      path.logs: /var/log/elasticsearch
      
      # ----------------------------------- Memory -----------------------------------
      
      # Lock the memory on startup:
      # bootstrap.memory_lock: true
      
      # Make sure that the heap size is set to about half the memory available
      # on the system and that the owner of the process is allowed to use this
      # limit.
      #
      # Elasticsearch performs poorly when the system is swapping the memory.
      
      # ---------------------------------- Network -----------------------------------
      
      # By default, Elasticsearch is only accessible on localhost. Set a different
      # address here to expose this node on the network:
      network.host: 0.0.0.0
      
      # By default, Elasticsearch listens for HTTP traffic on the first free port it
      # finds starting at 9200. Set a specific HTTP port here:
      http.port: 9200
      
      # For more information, consult the network module documentation.
      
      # --------------------------------- Discovery ----------------------------------
      
      # Pass an initial list of hosts to perform discovery when this node is started:
      # The default list of hosts is ["127.0.0.1", "[::1]"]
      discovery.seed_hosts: ["10.0.0.5","10.0.0.6"]
      
      # Bootstrap the cluster using an initial set of master-eligible nodes:
      cluster.initial_master_nodes: ["master-node-1"]
      
      # For more information, consult the discovery and cluster formation module documentation.
      
      # --------------------------------- Readiness ----------------------------------
      
      # Enable an unauthenticated TCP readiness endpoint on localhost
      # readiness.port: 9399
      
      # ---------------------------------- Various -----------------------------------
      
      # Allow wildcard deletion of indices:
      # action.destructive_requires_name: false
      
      # ----------------------- BEGIN SECURITY AUTO CONFIGURATION -----------------------
      
      # The following settings, TLS certificates, and keys have been automatically
      # generated to configure Elasticsearch security features on 13-07-2023 11:08:41
      
      # --------------------------------------------------------------------------------
      
      # Enable security features
      xpack.security.enabled: false
      
      xpack.security.enrollment.enabled: true
      
      # Enable encryption for HTTP API client connections, such as Kibana, Logstash, and Agents
      xpack.security.http.ssl:
        enabled: true
        keystore.path: certs/http.p12
      
      # Enable encryption and mutual authentication between cluster nodes
      xpack.security.transport.ssl:
        enabled: true
        verification_mode: certificate
        keystore.path: certs/transport.p12
        truststore.path: certs/transport.p12
      
      # Create a new cluster with the current node only
      # Additional nodes can still join the cluster later
      # cluster.initial_master_nodes: ["bp-es-poc"]
      
      # Allow HTTP API connections from anywhere
      # Connections are encrypted and require user authentication
      http.host: 0.0.0.0
      
      # Allow other nodes to join the cluster from anywhere
      # Connections are encrypted and mutually authenticated
      # transport.host: 0.0.0.0

      # ----------------------- END SECURITY AUTO CONFIGURATION -------------------------
      EOF

      sudo sh elasticsearch.sh
      systemctl start elasticsearch
      systemctl restart elasticsearch
      systemctl status elasticsearch

runcmd:
  - sudo bash /esinstallation.sh
