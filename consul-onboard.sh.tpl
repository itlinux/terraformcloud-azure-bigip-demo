#!/bin/bash
# https://github.com/hashicorp/f5-terraform-consul-sd-webinar/blob/master/scripts/consul.sh
# debian install consul
#Utils
sudo apt update
sudo apt-get install unzip jq -y

#Get IP
# aws
#local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
# azure
local_ipv4="$(curl -s http://169.254.169.254/metadata/instance?api-version=2019-06-01 -H "Metadata:true" | jq -r .network.interface[0].ipv4.ipAddress[0].privateIpAddress)"

#Download Consul
CONSUL_VERSION=${CONSUL_VERSION}
curl --silent --remote-name https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip

#Install Consul
unzip consul_${CONSUL_VERSION}_linux_amd64.zip
sudo chown root:root consul
sudo mv consul /usr/local/bin/
consul -autocomplete-install
complete -C /usr/local/bin/consul consul

#Create Consul User
sudo useradd --system --home /etc/consul.d --shell /bin/false consul
sudo mkdir --parents /opt/consul
sudo chown --recursive consul:consul /opt/consul

#Create Systemd Config
sudo cat << EOF > /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl
[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/usr/local/bin/consul reload
KillMode=process
Restart=always
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF

#Create config dir
sudo mkdir --parents /etc/consul.d
sudo touch /etc/consul.d/consul.hcl
sudo chown --recursive consul:consul /etc/consul.d
sudo chmod 640 /etc/consul.d/consul.hcl

cat << EOF > /etc/consul.d/consul.hcl
datacenter = "dc1"
data_dir = "/opt/consul"
ui = true
EOF

# aws
#cat << EOF > /etc/consul.d/client.hcl
#advertise_addr = "$${local_ipv4}"
#retry_join = ["provider=aws tag_key=Env tag_value=consul"]
#EOF
# cat << EOF > /etc/consul.d/server.hcl
# server = true
# bootstrap_expect = 1
# client_addr = "0.0.0.0"
# retry_join = ["provider=aws tag_key=Env tag_value=consul"]
# EOF
# azure
cat << EOF > /etc/consul.d/client.hcl
bind_addr = "$${local_ipv4}"
advertise_addr = "$${local_ipv4}"
client_addr = "0.0.0.0"
retry_join = ["provider=azure tag_name=environment tag_value=f5env tenant_id=1 client_id=1 subscription_id=1 secret_access_key=123"]
EOF
cat << EOF > /etc/consul.d/server.hcl
server = true
bootstrap_expect = 1
client_addr = "0.0.0.0"
retry_join = ["provider=azure tag_name=environment tag_value=f5env tenant_id=1 client_id=1 subscription_id=1 secret_access_key=123"]
EOF
# nginx
cat << EOF > /etc/consul.d/nginx.json
{
  "service": {
    "name": "nginx",
    "port": 80,
    "checks": [
      {
        "id": "nginx",
        "name": "nginx TCP Check",
        "tcp": "localhost:80",
        "interval": "10s",
        "timeout": "1s"
      }
    ]
  }
}
EOF
# juiceshop
cat << EOF > /etc/consul.d/juice.json
{
  "service": {
    "name": "juice",
    "port": 3000,
    "checks": [
      {
        "id": "juice",
        "name": "TCP Check",
        "tcp": "localhost:3000",
        "interval": "10s",
        "timeout": "1s"
      }
    ]
  }
}
EOF

#Enable the service
sudo systemctl enable consul
sudo service consul start
sudo service consul status

# install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh
# install compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
#Run  nginx
sleep 10
cat << EOF > docker-compose.yml
version: "3.7"
services:
  web:
    image: nginxdemos/hello
    ports:
    - "80:80"
    restart: always
    command: [nginx-debug, '-g', 'daemon off;']
    network_mode: "host"
  juice:
    image: bkimminich/juice-shop
    ports:
    - "3000:3000"
    restart: always
    network_mode: "host"
EOF
sudo docker-compose up -d