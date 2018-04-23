#!/bin/bash

pmm-admin config --server pmm-server
pmm-admin add external:service --service-port=7400 cassandra_$(hostname)
