#!/bin/bash
docker stop v2rayb 2>/dev/null
docker rm v2rayb 2>/dev/null
docker run -d \
  --restart=always \
  --privileged \
  --network=host \
  --name v2rayb \
  -e V2RAYB_ADDRESS=0.0.0.0:50541 \
  -v /lib/modules:/lib/modules:ro \
  -v /etc/resolv.conf:/etc/resolv.conf \
  -v /etc/v2rayb:/etc/v2rayb \
  v2rayb
