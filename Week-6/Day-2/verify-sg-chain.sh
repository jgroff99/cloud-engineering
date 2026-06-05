#!/bin/bash
# verify-sg-chain.sh
# Run from alb-instance to verify SG chain is working correctly
# Usage: bash verify-sg-chain.sh <app-private-ip> <db-private-ip>

APP_IP=$1
DB_IP=$2

if [ -z "$APP_IP" ] || [ -z "$DB_IP" ]; then
  echo "Usage: bash verify-sg-chain.sh <app-private-ip> <db-private-ip>"
  exit 1
fi

echo "========================================"
echo " SG Chain Verification"
echo "========================================"

echo ""
echo "Test 1: alb-instance → app-instance port 80"
result=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 http://$APP_IP)
if [ "$result" = "200" ] || [ "$result" = "403" ]; then
  echo "PASS — port 80 reachable from alb-instance (HTTP $result)"
else
  echo "FAIL — could not reach app-instance on port 80"
fi

echo ""
echo "Test 2: alb-instance → db-instance port 3306"
timeout 5 bash -c "cat < /dev/null > /dev/tcp/$DB_IP/3306" 2>/dev/null
if [ $? -eq 0 ]; then
  echo "FAIL — db-instance port 3306 reachable from alb-instance (should be blocked)"
else
  echo "PASS — db-instance port 3306 blocked from alb-instance"
fi

echo ""
echo "========================================"
echo " Done"
echo "========================================"
