# Node K8s on ubuntu 22.04 on Hyper-V VM
sudo apt update &&  sudo apt upgrade -y && sudo reboot
#wait for reboot
sudo hostnamectl set-hostname "tk8sn1.local"
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt update &&  sudo apt install -y containerd.io nano curl gnupg2 software-properties-common apt-transport-https ca-certificates kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo  nano /etc/hosts  
# # k8 cluster nodes
        10.123.104.112 tk8sm1.local tk8sm1
        10.123.104.113 tk8sn1.local tk8sn1
        10.123.104.114 tk8sn2.local tk8sn2

containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay && sudo modprobe br_netfilte
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1sudo
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
swapoff -a 
sudo vi /etc/fstab 
# remove swap (comment it out) and reboot
sudo kubeadm join tk8sm1.local:6443 --token dxl0iq.tghysm3xqrkctq2h --discovery-token-ca-cert-hash sha256:57559d46cd4d3ea3171f194b733b8d336cf5788e28d375a663163b589df2a7c0