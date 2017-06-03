#!/bin/bash

docker rm -f toolghostalpha && \
docker run -d --name=toolghostalpha \
-e PORT=2368 \
-p:2368:2368 \
fixer/ghostfixer:alpha

# devmtl/ghostalpha-fire:edge_2017-06-03_00H10