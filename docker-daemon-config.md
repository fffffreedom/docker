| 配置项| 默认值| 配置值| 描述|
|:---|:---|:---|:---|
| --add-runtime|| N/A | Register an  additional OCI compatible runtime |
| --api-cors-header|| N/A| Set  CORS headers in the remote API To set cross origin requests to the remote api please give values to  --api-cors-header when running Docker in  daemon mode. Set * (asterisk) allows all, default or blank means CORS  disabled    e.g.dockerd -H="172.25.34.32:2375"  -H="unix:///var/run/docker.sock"  --api-cors-header="http://foo.bar" |
| --authorization-plugin|| N/A| Authorization plugins  to load|
| --bridge, -b|| N/A| Attach containers to  a network bridge|
| --bip|| N/A| Specify network  bridge IP|
| --cgroup-parent|| N/A| Set parent cgroup for  all containers|
| --cluster-advertise|| N/A| Address or interface  name to advertise|
| --cluster-store| map[]| N/A| Set cluster store  options|
| --config-file| /etc/docker/daemon.json | /etc/docker/daemon.json| Daemon configuration  file|
| --containerd|| N/A| Path to containerd  socket|
| --debug, -D|| false  - 生产    true - 研发| Enable  debug mode|
| --default-gateway|| N/A| Container default  gateway IPv4 address  |
| --default-gateway-v6|| N/A| Container default  gateway IPv6 address  |
| --default-runtime| runc| runc| Default OCI runtime  for containers|
| --default-ulimit||| Default ulimits for  containers|
| --disable-legacy-registry|| true| Disable contacting  legacy registries|
| --dns|| N/A| DNS  server to use 添加 DNS 服务器到容器的 /etc/resolv.conf 中，让容器用这个服务器来解析所有不在 /etc/hosts 中的主机名。 |
| --dns-opt|| N/A| DNS options to use|
| --dns-search|| N/A| DNS  search domains to use    设定容器的搜索域，当设定搜索域为 .example.com 时，在搜索一个名为 host 的主机时，DNS 不仅搜索host，还会搜索  host.example.com。 |
| --exec-opt||| Runtime execution  options|
| --exec-root| /var/run/docker| /var/run/docker| Root directory for  execution state files |
| --fixed-cidr|| N/A| IPv4 subnet for fixed  IPs|
| --fixed-cidr-v6|| N/A| IPv6 subnet for fixed  IPs|
| --group, -G| docker| N/A| Group  for the unix socket 在后台运行模式下，赋予指定的Group到相应的unix socket上。注意，当此参数 --group 赋予空字符串时，将去除组信息 |
| --graph, -g| /var/lib/docker| /var/lib/docker| Root of the Docker  runtime|
| --host, -H|| -H="unix:///var/run/docker.sock"  -H="X.X.X.X:2376" | Daemon  socket(s) to connect to 设置后台模式下指定socket绑定，可以绑定一个或多个 tcp://host:port, unix:///path/to/socket, fd://*  或 fd://socketfd。如：$ docker -H tcp://0.0.0.0:2375 ps 或者$ export  DOCKER_HOST="tcp://0.0.0.0:2375"$ docker ps |
| --icc| TRUE| true| Enable  inter-container communication    |
| --insecure-registry||| Enable insecure  registry communication  |
| --ip| 0.0.0.0| 0.0.0.0| Default IP when  binding container ports |
| --ip-forward| TRUE| N/A| Enable  net.ipv4.ip_forward|
| --ip-masq| TRUE| N/A| Enable IP  masquerading|
| --iptables| TRUE| N/A| Enable addition of  iptables rules       |
| --ipv6|| false| Enable IPv6  networking|
| --log-level,  -l| info| info| Set the logging level|
| --label|| N/A| Set key=value labels  to the daemon|
| --live-restore|| true| Enables keeping  containers alive during daemon downtime |
| --log-driver| json-file| fluentd| Default driver for  container logs|
| --log-opt| map[]| N/A| Default log driver  options for containers |
| --max-concurrent-downloads| 3| 3| Set the max  concurrent downloads for each pull |
| --max-concurrent-uploads| 5| 5| Set the max  concurrent uploads for each push |
| --metrics-addr||| Set address and port  to serve the metrics api |
| --mtu|| N/A| Set the containers  network MTU|
| --oom-score-adjust| -500| -998| Set  the oom_score_adj for the daemon        保证在宿主机发生 OOM 状况时，docker daemon 和容器相比，容器更有可能被杀死 |
| --pidfile, -p| /var/run/docker.pid| N/A| Path to use for  daemon PID file|
| --raw-logs|| true| Full timestamps  without ANSI coloring   |
| --registry-mirror||| Preferred Docker  registry mirror|
| --storage-driver,  -s|| overlay| Storage  driver to use 设置容器运行时使用指定的存储驱动，如,指定使用devicemapper |
| --selinux-enabled|| false| Enable selinux  support|
| --storage-opt|| N/A| Storage driver  options|
| --swarm-default-advertise-addr || N/A| Set default address  or interface for swarm advertised address |
| --tls||| Use TLS; implied by  –tlsverify|
| --tlscacert| ~/.docker/ca.pem| "/var/docker/ca.pem"| Trust certs signed  only by this CA|
| --tlscert| ~/.docker/cert.pem| "/var/docker/server-cert.pem"            | Path to TLS  certificate file|
| --tlskey| ~/.docker/key.pem| "/var/docker/server-key.pem"| Path to TLS key file|
| --tlsverify|| true| Use TLS and verify  the remote|
| --userland-proxy| true| true| Use  userland proxy for loopback traffic 从docker daemon的角度，添加了userland-proxy的起停开关         首先介绍userland-proxy一直以来的作用。众所周知，在Docker的桥接bridge网络模式下，Docker容器时是通过宿主机上的NAT模式，建立与宿主机之外世界的通信。然而在宿主机上，一般情况下，进程可以通过三种方式访问容器，分别为：<eth0IP>:<hostPort>,  <containerIP>:<containerPort>,以及<0.0.0.0>:<hostPort>。实际上，最后一种方式的成功访问完全得益于userland-proxy，即Docker  Daemon在启动一个Docker容器时，每为容器在宿主机上映射一个端口，都会启动一个docker-proxy进程，实现宿主机上0.0.0.0地址上对容器的访问代理。        当时引入userland-proxy时，也许是因为设计者意识到了0.0.0.0地址对容器访问上的功能缺陷。然而，在docker-proxy加入Docker之后相当长的一段时间内。Docker爱好者普遍感受到，很多场景下，docker-proxy并非必需，甚至会带来一些其他的弊端。        影响较大的场景主要有两种。         第一，单个容器需要和宿主机有多个端口的映射。此场景下，若容器需要映射1000个端口甚至更多，那么宿主机上就会创建1000个甚至更多的docker-proxy进程。据不完全测试，每一个docker-proxy占用的内存是4-10MB不等。如此一来，直接消耗至少4-10GB内存，以及至少1000个进程，无论是从系统内存，还是从系统CPU资源来分析，这都会是很大的负担。         第二，众多容器同时存在于宿主机的情况，单个容器映射端口极少。这种场景下，关于宿主机资源的消耗并没有如第一种场景下那样暴力，而且一种较为慢性的方式侵噬资源。        如今，Docker Daemon引入- -userland-proxy这个flag，将以上场景的控制权完全交给了用户，由用户决定是否开启，也为用户的场景的proxy代理提供了灵活性 |
| --userns-remap|| N/A| User/Group setting  for user namespaces  |
