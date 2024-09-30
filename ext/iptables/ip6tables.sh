
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

# 接受 ICMP
# ip6tables -A INPUT -p icmp -j ACCEPT
ip6tables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
ip6tables -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
ip6tables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
ip6tables -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
ip6tables -A INPUT -p icmp --icmp-type parameter-problem -j ACCEPT

# 接受 ICMPv6
# ip6tables -A INPUT -p ipv6-icmp -j ACCEPT
# 接受 ICMPv6 基础功能
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type destination-unreachable -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type packet-too-big -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type time-exceeded -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type parameter-problem -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type echo-request -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type echo-reply -j ACCEPT
# 接受 IPv6 SLAAC
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type nd-router-solicit -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type nd-router-advert -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type nd-neighbor-solicit -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type nd-neighbor-advert -j ACCEPT
# 接受 IPv6 本地邻居发现
ip6tables -A INPUT -s fe80::/10 -p ipv6-icmp --icmpv6-type mld-listener-query -j ACCEPT
ip6tables -A INPUT -s fe80::/10 -p ipv6-icmp --icmpv6-type mld-listener-report -j ACCEPT
ip6tables -A INPUT -s fe80::/10 -p ipv6-icmp --icmpv6-type mld-listener-reduction -j ACCEPT
ip6tables -A INPUT -s fe80::/10 -p ipv6-icmp --icmpv6-type mld2-listener-report -j ACCEPT
# ip6tables -A INPUT -s fe80::/10 -p ipv6-icmp -j ACCEPT
# DHCPv6
ip6tables -A INPUT -p udp --sport 547 --dport 546 -j ACCEPT

# 跳向拦截表
ip6tables -A INPUT -j IN_FILTER

## 出站

ip6tables -P OUTPUT ACCEPT

## 转发

ip6tables -P FORWARD DROP

## 反向路径过滤
# --loose 宽松模式
# table: raw | mangle
ip6tables -t mangle -I PREROUTING -m rpfilter --invert -j DROP

### 应用规则

## 传入

# ssh
ip6tables -I IN_FILTER -p tcp --dport 22 -j ACCEPT
# http server
ip6tables -I IN_FILTER -p tcp --dport 80,443 -j ACCEPT
ip6tables -I IN_FILTER -p udp --dport 80,443 -j ACCEPT

# kde connect
ip6tables -I IN_FILTER -p tcp --dport 1714:1764 -j ACCEPT
ip6tables -I IN_FILTER -p udp --dport 1714:1764 -j ACCEPT

# 传出
