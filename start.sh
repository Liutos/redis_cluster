#!/bin/bash
echo "开始启动 6 个 Redis 实例。"
for port in 8000 8001 8002 8003 8004 8005 ;
do
    # --name 选项让这 6 个容器拥有确定的且不同的主机名，以便之后可以在 redis-cli 中指定它们。
    # --network 选项让这 6 个容器处于同一个网络下，以便集群内的节点可以互相通信。
    docker run --name "some-redis-${port}" --network some-network --rm -d -v "`pwd`/${port}:/usr/local/etc/redis" redis redis-server '/usr/local/etc/redis/redis.conf'
done

echo "检查 Redis 集群是否已经创建。"
docker run --network some-network --rm -i -t redis redis-cli --cluster check some-redis-8000:8000 | grep 'All 16384 slots covered.' > /dev/null
if [[ "$?" == '0' ]]; then
    echo "Redis 集群已经创建好了。"
else
    echo "开始创建 Redis 集群。"
    docker run --network some-network --rm -i -t redis redis-cli --cluster create some-redis-8000:8000 some-redis-8001:8001 some-redis-8002:8002 some-redis-8003:8003 some-redis-8004:8004 some-redis-8005:8005 --cluster-replicas 1 --cluster-yes
fi
