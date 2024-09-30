
### 基础规则

# 新建拦截表
iptables -N BLOCKER
# TCP 默认以 tcp-reset 拒绝
iptables -A BLOCKER -p tcp -j REJECT --reject-with tcp-reset
# UDP 默认以 icmp-port-unreachable 拒绝
iptables -A BLOCKER -p udp -j REJECT --reject-with icmp-port-unreachable
# 其他则以 icmp-proto-unreachable 拦截
iptables -A BLOCKER -j REJECT --reject-with icmp-proto-unreachable


## 传入

# 新建过滤表
iptables -N IN_FILTER
# 跳向拦截表
iptables -A IN_FILTER -j BLOCKER

# INPUT 链默认丢弃
iptables -P INPUT DROP
# 允许已建立的连接
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
# 允许本地环回连接
iptables -A INPUT -i lo -j ACCEPT
# ICMPv6 Neighbor Discovery
iptables -A INPUT -p 41 -j ACCEPT
# 丢弃无效连接
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
# 接受 ICMP
# iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
iptables -A INPUT -p icmp --icmp-type parameter-problem -j ACCEPT
# 跳向拦截表
iptables -A INPUT -j IN_FILTER

## 出站

iptables -P OUTPUT ACCEPT

## 转发

iptables -P FORWARD DROP

## 反向路径过滤
# 同 net.ipv4.conf.all.rp_filter=1
# --loose 宽松模式
# table: raw | mangle
iptables -t mangle -I PREROUTING -m rpfilter --invert -j DROP

### 应用规则

## 传入

# ssh
iptables -I IN_FILTER -p tcp --dport 22 -j ACCEPT
# http server
iptables -I IN_FILTER -p tcp --dport 80,443 -j ACCEPT
iptables -I IN_FILTER -p udp --dport 80,443 -j ACCEPT

# kde connect
iptables -I IN_FILTER -p tcp --dport 1714:1764 -j ACCEPT
iptables -I IN_FILTER -p udp --dport 1714:1764 -j ACCEPT

# 传出
