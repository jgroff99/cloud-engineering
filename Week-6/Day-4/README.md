# Week 6 Day 4 — Route 53

## What I built
- Private hosted zone (`myapp.internal`) associated with existing VPC
- A record: `db.internal.myapp.internal` → EC2 private IP
- Verified DNS resolution from inside the VPC using EC2 Instance Connect

## Key concepts
- Route 53 does three things: domain registration, DNS hosting, health checking
- Public hosted zone: resolves from the internet
- Private hosted zone: resolves only within an associated VPC — used for internal service discovery
- Record name + zone name = full DNS name (e.g. `db` + `myapp.internal` = `db.myapp.internal`)
- VPC must have DNS resolution and DNS hostnames enabled for private zones to work

## The 7 routing policies
| Policy | Use when |
|---|---|
| Simple | Single resource, no failover |
| Weighted | A/B testing, canary deployments |
| Latency-based | Global app, route to fastest region |
| Failover | Active/passive DR |
| Geolocation | Compliance, data residency (GDPR) |
| Geoproximity | Fine-grained geographic routing with bias |
| Multivalue | Multiple healthy IPs, no load balancer |
