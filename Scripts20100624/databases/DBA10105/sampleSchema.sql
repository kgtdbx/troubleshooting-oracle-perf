connect "SYSTEM"/"&&systemPassword"
set echo on
spool /u00/app/oracle/admin/DBA10105/scripts/sampleSchema.log
@/u00/app/oracle/product/10.1.0.5/demo/schema/mksample.sql &&systemPassword &&sysPassword change_on_install change_on_install change_on_install change_on_install change_on_install change_on_install EXAMPLE TEMP /u00/app/oracle/admin/DBA10105/scripts/
spool off
