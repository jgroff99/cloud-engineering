# Architecture Diagram — Multi-tier Security

## Network layout
┌─────────────────────────────────────────────────────┐
│  VPC 10.0.0.0/16                                    │
│                                                     │
│  ┌──────────────────────────────────────────────┐   │
│  │  Public Subnet                               │   │
│  │                                              │   │
│  │  ┌─────────────┐                             │   │
│  │  │ alb-instance│ ← alb-sg                   │   │
│  │  │ 10.0.x.x    │   port 80/443 from internet │   │
│  │  └──────┬──────┘   port 22 from My IP        │   │
│  │         │                                    │   │
│  └─────────┼────────────────────────────────────┘   │
│            │ port 80 (alb-sg as source)              │
│  ┌─────────┼────────────────────────────────────┐   │
│  │  Private Subnet                              │   │
│  │         ↓                                    │   │
│  │  ┌─────────────┐                             │   │
│  │  │ app-instance│ ← app-sg                   │   │
│  │  │ 10.0.x.x    │   port 80 from alb-sg only  │   │
│  │  └──────┬──────┘   port 22 from alb-sg only  │   │
│  │         │                                    │   │
│  │         │ port 3306 (app-sg as source)        │   │
│  │         ↓                                    │   │
│  │  ┌─────────────┐                             │   │
│  │  │ db-instance │ ← db-sg                    │   │
│  │  │ 10.0.x.x    │   port 3306 from app-sg only│   │
│  │  └─────────────┘                             │   │
│  │                                              │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
## Traffic flow
1. User hits alb-instance public IP on port 80
2. alb-sg allows it through
3. alb-instance forwards to app-instance private IP on port 80
4. app-sg allows it — source is alb-sg
5. app-instance queries db-instance on port 3306
6. db-sg allows it — source is app-sg
7. Response flows back through the chain automatically (SGs are stateful)

## What is blocked
- Direct internet access to app-instance — no public IP, app-sg has no internet rule
- Direct internet access to db-instance — no public IP, db-sg has no internet rule
- alb-instance → db-instance port 3306 — alb-sg not in db-sg allow rules
- Any unrecognized source → any tier — implicit deny on all SGs
