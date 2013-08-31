echo DROP DATABASE ozb_tdd | mysql -u root -proot
echo CREATE DATABASE ozb_tdd | mysql -u root -proot

mysql -u root -proot ozb_tdd < script/testdbDump.sql
