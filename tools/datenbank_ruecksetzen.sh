#1/bin/bash
PASS=""
echo "drop database ozb_test" | mysql -u root -p$PASS
echo "create database ozb_test" | mysql -u root -p$PASS
mysql -u root -p$PASS ozb_test < dump.sql
