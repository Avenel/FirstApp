#!/bin/bash
PASS="root"
echo "drop database ozb_prod" | mysql -u root -p$PASS
echo "create database ozb_prod" | mysql -u root -p$PASS
mysql -u root -p$PASS ozb_prod < ozb_prod_12-12-31.sql
echo "drop database ozb_test" | mysql -u root -p$PASS
echo "create database ozb_test" | mysql -u root -p$PASS
java -jar OZBMigration.jar -i ./create_tables.txt -u root -p $PASS

echo "bootstrap (adding default values for developing purposes)"
cd ../ozbapp/
bundle exec rake db:seed

mysqldump -u root -p$PASS ozb_test > dump.sql