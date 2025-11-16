# ============================================================================
# MODULES/EKS/user-data.sh
# ============================================================================

#!/bin/bash
set -o xtrace

# Bootstrap EKS node
/etc/eks/bootstrap.sh ${cluster_name} ${bootstrap_arguments}

# Install SSM Agent
yum install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Disable unnecessary services
systemctl disable postfix
systemctl stop postfix

# Configure system limits
cat >> /etc/security/limits.conf <<EOF
* soft nofile 65536
* hard nofile 65536
* soft nproc 65536
* hard nproc 65536
EOF

# Configure sysctl for Kubernetes
cat >> /etc/sysctl.d/99-kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
vm.overcommit_memory=1
kernel.panic=10
kernel.panic_on_oops=1
EOF

sysctl --system

# Install CloudWatch Agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Security hardening
chmod 700 /root
chmod 600 /root/.ssh/authorized_keys

# Disable core dumps
echo "* hard core 0" >> /etc/security/limits.conf

echo "Node bootstrap completed successfully"