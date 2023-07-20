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
      echo "kibana-8" 
      wget https://artifacts.elastic.co/downloads/kibana/kibana-8.3.3-amd64.deb
      shasum -a 512 kibana-8.3.3-amd64.deb
      sudo DEBIAN_FRONTEND=noninteractive dpkg -i kibana-8.3.3-amd64.deb 

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

      # Downloading the Kibana package:
      wget https://artifacts.elastic.co/downloads/kibana/kibana-8.3.3-amd64.deb
      # Verify the integrity of the downloaded package using the SHA512 checksum:
      shasum -a 512 kibana-8.3.3-amd64.deb
      # Install the Kibana package:
      sudo dpkg -i kibana-8.3.3-amd64.deb
      # To check the Kibana version:
      #sudo dpkg -s kibana | grep Version
      sudo mkdir /etc/kibanaymlcopy
      sudo cp /etc/kibana/kibana.yml /etc/kibana/kibana.yml.backup
      cat > kibana.sh << EOF
      #!/bin/bash
      sudo cat > /etc/kibana/kibana.yml << 'EOF'
      # For more configuration options see the configuration guide for Kibana in
      # https://www.elastic.co/guide/index.html

      # =================== System: Kibana Server ===================
      # Kibana is served by a back end server. This setting specifies the port to use.
      server.port: 5601

      # Specifies the address to which the Kibana server will bind. IP addresses and host names are both valid values.
      # The default is 'localhost', which usually means remote machines will not be able to connect.
      # To allow connections from remote users, set this parameter to a non-loopback address.
      server.host: "0.0.0.0"

      # Enables you to specify a path to mount Kibana at if you are running behind a proxy.
      # from requests it receives, and to prevent a deprecation warning at startup.
      # This setting cannot end in a slash.

      # Specifies whether Kibana should rewrite requests that are prefixed with

      # Specifies the public URL at which Kibana is available for end users. If
      server.publicBaseUrl: "http://10.0.0.5:5601"

      # The maximum payload size in bytes for incoming server requests.
      #server.maxPayload: 1048576

      # The Kibana server's name. This is used for display purposes.
      server.name: "elasticsearch-kibana"

      # =================== System: Kibana Server (Optional) ===================
      # Enables SSL and paths to the PEM-format SSL certificate and SSL key files, respectively.
      # These settings enable SSL for outgoing requests from the Kibana server to the browser.
      #server.ssl.enabled: false
      #server.ssl.certificate: /path/to/your/server.crt
      #server.ssl.key: /path/to/your/server.key

      # =================== System: Elasticsearch ===================
      # The URLs of the Elasticsearch instances to use for all your queries.
      elasticsearch.hosts: ["http://10.0.0.5:9200","http://10.0.0.6:9200"]

      # If your Elasticsearch is protected with basic authentication, these settings provide
      #elasticsearch.requestTimeout: 30000

      # The maximum number of sockets that can be used for communications with Elasticsearch.
      #elasticsearch.maxSockets: 1024
      # Specifies whether Kibana should use compression for communications with Elasticsearch
      # Defaults to `false`.
      #elasticsearch.compression: false
      # the username and password that the Kibana server uses to perform maintenance on the Kibana
      # index at startup. Your Kibana users still need to authenticate with Elasticsearch, which
      # is proxied through the Kibana server.
      #elasticsearch.username: "kibana_system"
      # Logs queries sent to Elasticsearch.
      #logging.loggers:
      #  - name: elasticsearch.query
      #    level: debug

      # Logs http responses.
      #logging.loggers:
      #  - name: http.server.response
      #    level: debug

      # Logs system usage information.
      #elasticsearch.password: "pass"
      # Set the interval in milliseconds to sample system and process performance
      # metrics. Minimum is 100ms. Defaults to 5000ms.
      #ops.interval: 5000

      # Specifies locale to be used for all localizable strings, dates and number formats.
      # Supported languages are the following: English (default) "en", Chinese "zh-CN", Japanese "ja-JP", French "fr-FR".
      # Kibana can also authenticate to Elasticsearch via "service account tokens".
      # Service account tokens are Bearer style tokens that replace the traditional username/password based configuration.
      # Use this token instead of a username/password.
      # elasticsearch.serviceAccountToken: "my_token"

      # Time in milliseconds to wait for Elasticsearch to respond to pings. Defaults to the value of
      # the elasticsearch.requestTimeout setting.
      #elasticsearch.pingTimeout: 1500

      # Time in milliseconds to wait for responses from the back end or Elasticsearch. This value
      # must be a positive integer.
      #elasticsearch.requestTimeout: 30000

      # The maximum number of sockets that can be used for communications with Elasticsearch.
      #elasticsearch.maxSockets: 1024
      # Specifies whether Kibana should use compression for communications with Elasticsearch
      # Defaults to `false`.
      #elasticsearch.compression: false

      # List of Kibana client-side headers to send to Elasticsearch. To send *no* client-side
      # headers, set this value to [] (an empty list).
      #elasticsearch.requestHeadersWhitelist: [ authorization ]

      # Header names and values that are sent to Elasticsearch. Any custom headers cannot be overwritten
      # by client-side headers, regardless of the elasticsearch.requestHeadersWhitelist configuration.
      #elasticsearch.customHeaders: {}

      # Time in milliseconds for Elasticsearch to wait for responses from shards. Set to 0 to disable.
      #elasticsearch.shardTimeout: 30000

      # =================== System: Elasticsearch (Optional) ===================
      # These files are used to verify the identity of Kibana to Elasticsearch and are required when
      # xpack.security.http.ssl.client_authentication in Elasticsearch is set to required.
      #elasticsearch.ssl.certificate: /path/to/your/client.crt
      #elasticsearch.ssl.key: /path/to/your/client.key

      # Enables you to specify a path to the PEM file for the certificate
      # authority for your Elasticsearch instance.
      #elasticsearch.ssl.certificateAuthorities: [ "/path/to/your/CA.pem" ]

      # To disregard the validity of SSL certificates, change this setting's value to 'none'.
      #elasticsearch.ssl.verificationMode: full

      # =================== System: Logging ===================
      # Set the value of this setting to off to suppress all logging output, or to debug to log everything. Defaults to 'info'
      #logging.root.level: debug

      # Enables you to specify a file where Kibana stores log output.
      logging:
        appenders:
          file:
            type: file
            fileName: /var/log/kibana/kibana.log
            layout:
              type: json
        root:
          appenders:
            - default
            - file

      # Logs queries sent to Elasticsearch.
      #logging.loggers:
      #  - name: elasticsearch.query
      #    level: debug

      # Logs http responses.
      #logging.loggers:
      #  - name: http.server.response
      #    level: debug

      # Logs system usage information.
      #logging.loggers:
      #  - name: metrics.ops
      #    level: debug

      # =================== System: Other ===================
      # The path where Kibana stores persistent data not saved in Elasticsearch. Defaults to data
      #path.data: data

      # Specifies the path where Kibana creates the process ID file.
      pid.file: /run/kibana/kibana.pid

      # Set the interval in milliseconds to sample system and process performance
      # metrics. Minimum is 100ms. Defaults to 5000ms.
      #ops.interval: 5000

      # Specifies locale to be used for all localizable strings, dates and number formats.
      # Supported languages are the following: English (default) "en", Chinese "zh-CN", Japanese "ja-JP", French "fr-FR".
      #i18n.locale: "en"

      # =================== Frequently used (Optional)===================

      # =================== Saved Objects: Migrations ===================
      # Saved object migrations run at startup. If you run into migration-related issues, you might need to adjust these settings.

      # The number of documents migrated at a time.
      # use a smaller batchSize value to reduce the memory pressure. Defaults to 1000 objects per batch.
      #migrations.batchSize: 1000

      # The maximum payload size for indexing batches of upgraded saved objects.
      # To avoid migrations failing due to a 413 Request Entity Too Large response from Elasticsearch.
      # configuration option. Default: 100mb
      #migrations.maxBatchSizeBytes: 100mb

      # The number of times to retry temporary migration failures. Increase the setting
      # 15 attempts, terminating. Defaults to 15
      #migrations.retryAttempts: 15

      # =================== Search Autocomplete ===================
      # Time in milliseconds to wait for autocomplete suggestions from Elasticsearch.
      # This value must be a whole number greater than zero. Defaults to 1000ms
      #unifiedSearch.autocomplete.valueSuggestions.timeout: 1000

      # Maximum number of documents loaded by each shard to generate autocomplete suggestions.
      # This value must be a whole number greater than zero. Defaults to 100_000
      #unifiedSearch.autocomplete.valueSuggestions.terminateAfter: 100000
      EOF


      sudo sh kibana.sh

      systemctl start elasticsearch
      systemctl restart elasticsearch
      systemctl start kibana

      systemctl status elasticsearch
      systemctl status kibana

runcmd:
  - sudo bash /esinstallation.sh
