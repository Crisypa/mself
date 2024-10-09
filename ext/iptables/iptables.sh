
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
# echo-reply type 0
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
# destination-unreachable type 3
iptables -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
# echo-request type 8
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
# time-exceeded type 11
iptables -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
# parameter-problem type 12
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
# iptables -t raw -I PREROUTING -m rpfilter --invert -j DROP
# iptables -t mangle -I PREROUTING -m rpfilter --invert -j DROP

### 应用规则

## 传入

# 基础服务
# ssh
iptables -I IN_FILTER -p tcp --dport 22 -j ACCEPT
# http server
iptables -I IN_FILTER -p tcp --dport 80,443 -j ACCEPT
iptables -I IN_FILTER -p udp --dport 80,443 -j ACCEPT

# 可选服务
# kde connect
# iptables -I IN_FILTER -p tcp --dport 1714:1764 --src 10.0.0.0/8 -j ACCEPT
# iptables -I IN_FILTER -p udp --dport 1714:1764 --src 10.0.0.0/8 -j ACCEPT
# iptables -I IN_FILTER -p tcp --dport 1714:1764 --src 172.16.0.0/12 -j ACCEPT
# iptables -I IN_FILTER -p udp --dport 1714:1764 --src 172.16.0.0/12 -j ACCEPT
# iptables -I IN_FILTER -p tcp --dport 1714:1764 --src 192.168.0.0/16 -j ACCEPT
# iptables -I IN_FILTER -p udp --dport 1714:1764 --src 192.168.0.0/16 -j ACCEPT
# DLNA 投屏
# iptables -I IN_FILTER -p tcp --dport 8200 --src 10.0.0.0/8 -j ACCEPT
# iptables -I IN_FILTER -p tcp --dport 8200 --src 172.16.0.0/12 -j ACCEPT
# iptables -I IN_FILTER -p tcp --dport 8200 --src 192.168.0.0/16 -j ACCEPT
# miracast
# iptables -I IN_FILTER -p tcp --dport 7250 --src 10.0.0.0/8 -j ACCEPT
# iptables -I IN_FILTER -p tcp --dport 7250 --src 172.16.0.0/12 -j ACCEPT
# iptables -I IN_FILTER -p tcp --dport 7250 --src 192.168.0.0/16 -j ACCEPT
# UPnP
# iptables -I IN_FILTER -p udp --dport 1900 --src 10.0.0.0/8 -j ACCEPT
# iptables -I IN_FILTER -p udp --dport 1900 --src 172.16.0.0/12 -j ACCEPT
# iptables -I IN_FILTER -p udp --dport 1900 --src 192.168.0.0/16 -j ACCEPT
# nebula
# iptables -I IN_FILTER -p udp -j ACCEPT
# iptables -I IN_FILTER -p udp --dport 4242 -j ACCEPT

# 传出
