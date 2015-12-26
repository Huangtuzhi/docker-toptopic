#!/bin/bash

/etc/init.d/mysql start
/etc/init.d/nginx start &
/home/toptopic/web/dataCGI.py
