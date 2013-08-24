#!/bin/bash
PASS="root"
echo "drop database ozb_tdd" | mysql -u root -p$PASS
echo "create database ozb_tdd" | mysql -u root -p$PASS

mysql -u root -p$PASS ozb_tdd < ./create_tables.txt
