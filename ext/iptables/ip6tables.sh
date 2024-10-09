
### 基础规则

# 新建拦截表
ip6tables -N BLOCKER
# TCP 默认以 tcp-reset 拒绝
ip6tables -A BLOCKER -p tcp -j REJECT --reject-with tcp-reset
# UDP 默认以 icmp-port-unreachable 拒绝
ip6tables -A BLOCKER -p udp -j REJECT --reject-with icmp6-port-unreachable
# 其他则以 icmp-proto-unreachable 拦截
ip6tables -A BLOCKER -j REJECT --reject-with icmp6-port-unreachable

## 传入

# 新建过滤表
ip6tables -N IN_FILTER
# 跳向拦截表
ip6tables -A IN_FILTER -j BLOCKER

# INPUT 链默认丢弃
ip6tables -P INPUT DROP

# 允许已建立的连接
ip6tables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
# 允许本地环回连接
ip6tables -A INPUT -i lo -j ACCEPT
# 丢弃无效连接
ip6tables -A INPUT -m conntrack --ctstate INVALID -j DROP
# 接受 ICMPv6
# ip6tables -A INPUT -p ipv6-icmp -j ACCEPT
# 基础 IPv6 icmp 功能
# destination-unreachable type 1
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type destination-unreachable -j ACCEPT
# packet-too-big type 2
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type packet-too-big -j ACCEPT
# time-exceeded type 3
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type time-exceeded -j ACCEPT
# parameter-problem type 4
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type parameter-problem -j ACCEPT
# echo-request type 128
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type echo-request -j ACCEPT
# echo-reply type 129
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type echo-reply -j ACCEPT
# IPv6 SLAAC
# ip6tables -A INPUT -m hl --hl-eq 255 -p ipv6-icmp -j ACCEPT
# router-solicitation type 133
ip6tables -A INPUT -m hl --hl-eq 255 -p ipv6-icmp --icmpv6-type router-solicitation -j ACCEPT
# router-advertisement type 134
ip6tables -A INPUT -m hl --hl-eq 255 -p ipv6-icmp --icmpv6-type router-advertisement -j ACCEPT
# neighbour-solicitation type 135
ip6tables -A INPUT -m hl --hl-eq 255 -p ipv6-icmp --icmpv6-type neighbour-solicitation -j ACCEPT
# neighbour-advertisement type 136
ip6tables -A INPUT -m hl --hl-eq 255 -p ipv6-icmp --icmpv6-type neighbour-advertisement -j ACCEPT
# 组播侦听发现协议
# ip6tables -A INPUT -p ipv6-icmp --src fe80::/10 -j ACCEPT
# mld-listener-query type 130
ip6tables -A INPUT --src fe80::/10 -p ipv6-icmp --icmpv6-type 130 -j ACCEPT
# mld-listener-report type 131
ip6tables -A INPUT --src fe80::/10 -p ipv6-icmp --icmpv6-type 131 -j ACCEPT
# mld-listener-reduction type 132
ip6tables -A INPUT --src fe80::/10 -p ipv6-icmp --icmpv6-type 132 -j ACCEPT
# mld2-listener-report type 143
ip6tables -A INPUT --src fe80::/10 -p ipv6-icmp --icmpv6-type 143 -j ACCEPT
# DHCPv6
# ip6tables -A INPUT -p udp --sport 547 --dport 546 -j ACCEPT
ip6tables -A INPUT -p udp --src fe80::/10 --sport 547 --dport 546 -j ACCEPT

# 跳向拦截表
ip6tables -A INPUT -j IN_FILTER

## 出站

ip6tables -P OUTPUT ACCEPT

## 转发

ip6tables -P FORWARD DROP

## 反向路径过滤
# --loose 宽松模式
# table: raw | mangle
# ip6tables -t raw -I PREROUTING -m rpfilter --invert -j DROP
ip6tables -t mangle -I PREROUTING -m rpfilter --invert -j DROP

### 应用规则

## 传入

# 基础服务
# ssh
ip6tables -I IN_FILTER -p tcp --dport 22 -j ACCEPT
# http server
ip6tables -I IN_FILTER -p tcp --dport 80,443 -j ACCEPT
ip6tables -I IN_FILTER -p udp --dport 80,443 -j ACCEPT

# 可选服务
# kde connect
# ip6tables -I IN_FILTER -p tcp --dport 1714:1764 --src fd00::/8 -j ACCEPT
# ip6tables -I IN_FILTER -p udp --dport 1714:1764 --src fd00::/8 -j ACCEPT
# ip6tables -I IN_FILTER -p tcp --dport 1714:1764 --src fe80::/10 -j ACCEPT
# ip6tables -I IN_FILTER -p udp --dport 1714:1764 --src fe80::/10 -j ACCEPT
# DLNA 投屏
# ip6tables -I IN_FILTER -p tcp --dport 8200 --src fd00::/8 -j ACCEPT
# ip6tables -I IN_FILTER -p tcp --dport 8200 --src fe80::/10 -j ACCEPT
# miracast
# ip6tables -I IN_FILTER -p tcp --dport 7250 --src fd00::/8 -j ACCEPT
# ip6tables -I IN_FILTER -p tcp --dport 7250 --src fe80::/10 -j ACCEPT
# UPnP
# ip6tables -I IN_FILTER -p udp --dport 1900 --src fd00::/8 -j ACCEPT
# ip6tables -I IN_FILTER -p udp --dport 1900 --src fe80::/10 -j ACCEPT
# nebula
# ip6tables -I IN_FILTER -p udp -j ACCEPT
# ip6tables -I IN_FILTER -p udp --dport 4242 -j ACCEPT

# 传出
