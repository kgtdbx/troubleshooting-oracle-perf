connect SYS/&&sysPassword as SYSDBA
set echo on
spool helicon:/u00/app/oracle/admin/DBA10103/scripts/interMedia.log
@/u00/app/oracle/product/10.1.0.3/ord/im/admin/iminst.sql;
spool off
