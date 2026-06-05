# Week 6 Day 3 — VPC Peering & Transit Gateway

## What I Built
A VPC peering connection between two private networks, proving cross-VPC communication over AWS's private backbone with no internet hop.

## Architecture
AWS Private Backbone
                           │
    ┌──────────────────────┴──────────────────────┐
    │                                             │
cloud-engineering-vpc                          peer-vpc
10.0.0.0/16                               10.1.0.0/16
us-east-2a public subnet               us-east-2a public subnet
10.0.0.0/20                               10.1.1.0/24
│                                             │
week6-instance                            peer-instance
(10.0.x.x)          ◄── pcx ──►          (10.1.1.14)
## Resources Created

| Resource | Name | Details |
|---|---|---|
| VPC | peer-vpc | 10.1.0.0/16 |
| Subnet | peer-public-subnet-a | 10.1.1.0/24 — us-east-2a |
| Internet Gateway | peer-igw | Attached to peer-vpc |
| Route Table | peer-public-rt | 0.0.0.0/0 → IGW, 10.0.0.0/16 → PCX |
| VPC Peering Connection | week6-peer | cloud-engineering-vpc ↔ peer-vpc |
| Security Group | peer-sg | Inbound ICMP + SSH from 10.0.0.0/16 |
| EC2 | peer-instance | t3.micro in peer-public-subnet-a |
| EC2 | week6-instance | t3.micro in cloud-engineering-vpc public subnet |

## Route Table Updates (Both Sides)

**cloud-engineering-vpc public route table:**
Destination     Target
10.0.0.0/16  →  local
10.1.0.0/16  →  pcx-xxxxxxxx  ← added for peering
0.0.0.0/0    →  igw
**peer-vpc route table:**
Destination     Target
10.1.0.0/16  →  local
10.0.0.0/16  →  pcx-xxxxxxxx  ← added for peering
0.0.0.0/0    →  igw
## What I Verified

- ✅ SSH into week6-instance from my machine
- ✅ Pinged 10.1.1.14 (peer-instance private IP) from week6-instance
- ✅ 0% packet loss, sub-millisecond latency — traffic stayed on AWS private backbone
- ✅ TTL of 255 confirmed single private hop, no internet routing

## Key Concepts

**VPC Peering constraints:**
- Non-transitive — A↔B and B↔C does not mean A can reach C via B
- No overlapping CIDRs — both VPCs must have distinct address spaces
- Route tables must be updated on both sides of every peering connection
- Security groups must explicitly allow traffic from the peer VPC's CIDR

**VPC Peering vs Transit Gateway:**

| | VPC Peering | Transit Gateway |
|---|---|---|
| Cost | Data transfer only | $0.05/hr per attachment + $0.02/GB |
| Management | Per-connection route tables | One central route table |
| Scale | 2–4 VPCs | 5+ VPCs |
| Transitive routing | No | Yes |
| VPN/Direct Connect | No | Yes |

**The scaling problem:**
- 10 VPCs fully meshed with peering = 45 peering connections
- 10 VPCs on Transit Gateway = 10 attachments, 1 route table
