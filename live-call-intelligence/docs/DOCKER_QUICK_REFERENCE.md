# Docker Quick Reference Guide

## 🚀 Starting & Stopping Services

### Start All Services
```bash
docker-compose -f docker-compose.dev.yml up -d

# Or use our script:
./scripts/docker-start.sh
```

### Stop All Services
```bash
docker-compose -f docker-compose.dev.yml down

# Or use our script:
./scripts/docker-stop.sh
```

### Restart All Services
```bash
docker-compose -f docker-compose.dev.yml restart
```

### Start Specific Service
```bash
docker-compose -f docker-compose.dev.yml up -d neo4j
```

---

## 📊 Checking Status

### View Running Containers
```bash
docker ps

# Or use our script:
./scripts/docker-status.sh
```

### View All Containers (Including Stopped)
```bash
docker ps -a
```

### View Container Logs
```bash
# All logs
docker logs call-intel-neo4j

# Follow logs (live)
docker logs -f call-intel-neo4j

# Last 100 lines
docker logs --tail 100 call-intel-neo4j
```

### View Resource Usage
```bash
docker stats
```

---

## 🔧 Interacting with Services

### Neo4j
```bash
# Access Neo4j Browser
Open: http://localhost:7474
Username: neo4j
Password: CallIntel123!

# Execute Cypher query from command line
docker exec -it call-intel-neo4j cypher-shell -u neo4j -p CallIntel123!
```

### Redis
```bash
# Access Redis CLI
docker exec -it call-intel-redis redis-cli

# Test Redis
docker exec -it call-intel-redis redis-cli ping
# Should return: PONG

# Get all keys
docker exec -it call-intel-redis redis-cli KEYS '*'
```

### PostgreSQL
```bash
# Access PostgreSQL CLI
docker exec -it call-intel-postgres psql -U admin -d call_intelligence

# Access via Adminer web UI
Open: http://localhost:8080
System: PostgreSQL
Server: postgres
Username: admin
Password: Admin123!
Database: call_intelligence
```

### Kafka
```bash
# List topics
docker exec -it call-intel-kafka kafka-topics --list --bootstrap-server localhost:9093

# Create topic
docker exec -it call-intel-kafka kafka-topics --create \
  --topic test-topic \
  --bootstrap-server localhost:9093 \
  --partitions 1 \
  --replication-factor 1

# Describe topic
docker exec -it call-intel-kafka kafka-topics --describe \
  --topic test-topic \
  --bootstrap-server localhost:9093
```

---

## 🧹 Cleanup Commands

### Remove Stopped Containers
```bash
docker container prune
```

### Remove Unused Images
```bash
docker image prune
```

### Remove Unused Volumes
```bash
docker volume prune
```

### Remove Everything (⚠️ DANGEROUS)
```bash
# Stops containers and removes volumes (data will be lost!)
docker-compose -f docker-compose.dev.yml down -v
```

### Full Cleanup
```bash
# Remove all stopped containers, unused networks, images, and volumes
docker system prune -a --volumes
```

---

## 🔄 Updating Services

### Rebuild Specific Service
```bash
docker-compose -f docker-compose.dev.yml up -d --build neo4j
```

### Pull Latest Images
```bash
docker-compose -f docker-compose.dev.yml pull
```

### Rebuild Everything
```bash
docker-compose -f docker-compose.dev.yml up -d --build --force-recreate
```

---

## �� Troubleshooting

### Service Won't Start
```bash
# Check logs
docker logs call-intel-neo4j

# Check if port is in use
# Windows:
netstat -ano | findstr :7474

# Mac/Linux:
lsof -i :7474

# Force remove and restart
docker rm -f call-intel-neo4j
docker-compose -f docker-compose.dev.yml up -d neo4j
```

### Container Keeps Restarting
```bash
# See why it's failing
docker logs call-intel-kafka

# Check container details
docker inspect call-intel-kafka
```

### Out of Disk Space
```bash
# Check disk usage
docker system df

# Clean up
docker system prune -a
```

### Can't Connect to Service
```bash
# Check if container is running
docker ps | grep call-intel

# Check network
docker network ls
docker network inspect live-call-intelligence_call-intel-network

# Verify port mapping
docker port call-intel-neo4j
```

---

## 📦 Volume Management

### List Volumes
```bash
docker volume ls
```

### Inspect Volume
```bash
docker volume inspect live-call-intelligence_neo4j_data
```

### Backup Neo4j Data
```bash
docker run --rm \
  -v live-call-intelligence_neo4j_data:/data \
  -v $(pwd):/backup \
  ubuntu tar czf /backup/neo4j-backup.tar.gz /data
```

### Restore Neo4j Data
```bash
docker run --rm \
  -v live-call-intelligence_neo4j_data:/data \
  -v $(pwd):/backup \
  ubuntu tar xzf /backup/neo4j-backup.tar.gz -C /
```

---

## 🔍 Useful Commands

### Enter Container Shell
```bash
docker exec -it call-intel-neo4j /bin/bash
```

### Copy Files to/from Container
```bash
# From container to host
docker cp call-intel-neo4j:/var/log/neo4j/debug.log ./neo4j-debug.log

# From host to container
docker cp ./config.yml call-intel-neo4j:/etc/config.yml
```

### Check Container Resource Limits
```bash
docker inspect call-intel-neo4j | grep -A 10 Resources
```

---

## 🎯 Quick Health Checks
```bash
# Check all services
docker-compose -f docker-compose.dev.yml ps

# Quick test all services
docker exec -it call-intel-redis redis-cli ping && echo "✅ Redis OK"
docker exec -it call-intel-neo4j cypher-shell -u neo4j -p CallIntel123! "RETURN 1" && echo "✅ Neo4j OK"
docker exec -it call-intel-postgres pg_isready && echo "✅ PostgreSQL OK"
docker exec -it call-intel-kafka kafka-broker-api-versions --bootstrap-server localhost:9093 && echo "✅ Kafka OK"
```

---

## 📍 Service URLs & Ports

| Service | URL/Port | Credentials |
|---------|----------|-------------|
| Neo4j Browser | http://localhost:7474 | neo4j / CallIntel123! |
| Neo4j Bolt | localhost:7687 | neo4j / CallIntel123! |
| Redis | localhost:6379 | (none) |
| Kafka | localhost:9092 | (none) |
| PostgreSQL | localhost:5432 | admin / Admin123! |
| Adminer | http://localhost:8080 | (see PostgreSQL) |

---

## 💡 Pro Tips

1. **Always use `-d` flag** - Runs containers in background
2. **Check logs first** - When something fails, logs usually explain why
3. **Don't delete volumes** - Unless you want to lose data
4. **Use our scripts** - They're easier than remembering commands
5. **Restart fixes most issues** - `docker-compose restart` solves many problems

---

## 🆘 Emergency Recovery

### Everything is broken, start fresh:
```bash
# 1. Stop everything
docker-compose -f docker-compose.dev.yml down

# 2. Remove containers (keeps data)
docker rm $(docker ps -aq)

# 3. Start fresh
docker-compose -f docker-compose.dev.yml up -d

# 4. Wait and verify
sleep 30
docker ps
```

**Still broken?** Ask in DevOps team channel!
