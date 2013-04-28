#!/bin/bash
PASS=""
echo "drop database ozb_prod" | mysql -u root -p$PASS
echo "create database ozb_prod" | mysql -u root -p$PASS
mysql -u root -p$PASS ozb_prod < ozb_prod.sql
echo "drop database ozb_test" | mysql -u root -p$PASS
echo "create database ozb_test" | mysql -u root -p$PASS
java -jar OZBMigration.jar -i ./create_tables.txt -u root -p $PASS
mysqldump -u root -p$PASS ozb_test > dump.sql
