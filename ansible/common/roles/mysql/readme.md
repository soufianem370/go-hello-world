# Mount point doc for nfs storage by ovh
 -  each mysql server have ftp storage given by ovh set in each fstab, todo ansible each fstab , in necessary you'll find desc in table :

| #nfs server source file system                                             | mountpoint         | type | options | dump | pass | # server location | server storage source location |
|----------------------------------------------------------------------------|--------------------|------|---------|------|------|-------------------|--------------------------------|
| ftpback-rbx4-112.ovh.net:/export/ftpbackup/ns3014240.ip-176-31-233.eu/data | /backup/data/node1 | nfs  | nolock  | 0    | 0    | # mysql03_mysql04 | mysql03-ns3014240              |
| ftpback-rbx4-112.ovh.net:/export/ftpbackup/ns3014240.ip-176-31-233.eu/log  | /backup/log/node1  | nfs  | nolock  | 0    | 0    | # mysql03_mysql04 | mysql03-ns3014240              |
| ftpback-rbx3-314.ovh.net:/export/ftpbackup/ns3014511.ip-46-105-105.eu/data | /backup/data/node2 | nfs  | nolock  | 0    | 0    | # mysql03_mysql04 | mysql04-ns3014511              |
| ftpback-rbx3-314.ovh.net:/export/ftpbackup/ns3014511.ip-46-105-105.eu/log  | /backup/log/node2  | nfs  | nolock  | 0    | 0    | # mysql03_mysql04 | mysql04-ns3014511              |
| ftpback-rbx4-106.ovh.net:/export/ftpbackup/ns3273415.ip-5-39-70.eu/data    | /backup/data/node3 | nfs  | nolock  | 0    | 0    | # mysql03_mysql04 | es-hot01-ns3273415             |
| ftpback-rbx4-106.ovh.net:/export/ftpbackup/ns3273415.ip-5-39-70.eu/log     | /backup/log/node3  | nfs  | nolock  | 0    | 0    | # mysql03_mysql04 | es-hot01-ns3273415             |
| ftpback-rbx4-159.ovh.net:/export/ftpbackup/ns3097212.ip-5-39-74.eu/data    | /backup/data/node4 | nfs  | nolock  | 0    | 0    | # mysql03_mysql04 | es-hot02-ns3097212             |
| ftpback-rbx4-159.ovh.net:/export/ftpbackup/ns3097212.ip-5-39-74.eu/log     | /backup/log/node4  | nfs  | nolock  | 0    | 0    | # mysql03_mysql04 | es-hot02-ns3097212             |
| ftpback-rbx3-215.ovh.net:/export/ftpbackup/ns3020885.ip-5-39-65.eu/data    | /backup/data/node1 | nfs  | nolock  | 0    | 0    | # mysql05_mysql06 | mysql05                        |
| ftpback-rbx3-215.ovh.net:/export/ftpbackup/ns3020885.ip-5-39-65.eu/log     | /backup/log/node1  | nfs  | nolock  | 0    | 0    | # mysql05_mysql06 | mysql05                        |
| ftpback-rbx3-219.ovh.net:/export/ftpbackup/ns3006869.ip-46-105-117.eu/data | /backup/data/node2 | nfs  | nolock  | 0    | 0    | # mysql05_mysql06 | mysql06                        |
| ftpback-rbx3-219.ovh.net:/export/ftpbackup/ns3006869.ip-46-105-117.eu/log  | /backup/log/node2  | nfs  | nolock  | 0    | 0    | # mysql05_mysql06 | mysql06                        |
| ftpback-rbx7-654.ovh.net:/export/ftpbackup/ns3115422.ip-5-39-69.eu/data    | /backup/data/node3 | nfs  | nolock  | 0    | 0    | # mysql05_mysql06 | es-hot05-ns3115422             |
| ftpback-rbx7-654.ovh.net:/export/ftpbackup/ns3115422.ip-5-39-69.eu/log     | /backup/log/node3  | nfs  | nolock  | 0    | 0    | # mysql05_mysql06 | es-hot05-ns3115422             |
| ftpback-rbx3-203.ovh.net:/export/ftpbackup/ns349410.ip-5-39-69.eu/data     | /backup/data/node4 | nfs  | nolock  | 0    | 0    | # mysql05_mysql06 | es-hot07-ns349410              |
| ftpback-rbx3-203.ovh.net:/export/ftpbackup/ns349410.ip-5-39-69.eu/log      | /backup/log/node4  | nfs  | nolock  | 0    | 0    | # mysql05_mysql06 | es-hot07-ns349410              |
| ftpback-rbx3-255.ovh.net:/export/ftpbackup/ns3015673.ip-176-31-229.eu/data | /backup/data/node1 | nfs  | nolock  | 0    | 0    | # mysql07_mysql08 | mysql07                        |
| ftpback-rbx3-255.ovh.net:/export/ftpbackup/ns3015673.ip-176-31-229.eu/log  | /backup/log/node1  | nfs  | nolock  | 0    | 0    | # mysql07_mysql08 | mysql07                        |
| ftpback-rbx2-106.ovh.net:/export/ftpbackup/ns3015674.ip-176-31-229.eu/data | /backup/data/node2 | nfs  | nolock  | 0    | 0    | # mysql07_mysql08 | mysql08                        |
| ftpback-rbx2-106.ovh.net:/export/ftpbackup/ns3015674.ip-176-31-229.eu/log  | /backup/log/node2  | nfs  | nolock  | 0    | 0    | # mysql07_mysql08 | mysql08                        |
| ftpback-rbx2-49.ovh.net:/export/ftpbackup/ns3115427.ip-5-39-69.eu/data     | /backup/data/node3 | nfs  | nolock  | 0    | 0    | # mysql07_mysql08 | es-hot08-ns3115427             |
| ftpback-rbx2-49.ovh.net:/export/ftpbackup/ns3115427.ip-5-39-69.eu/log      | /backup/log/node3  | nfs  | nolock  | 0    | 0    | # mysql07_mysql08 | es-hot08-ns3115427             |
| ftpback-rbx4-99.ovh.net:/export/ftpbackup/ns3012077.ip-5-39-68.eu/data     | /backup/data/node4 | nfs  | nolock  | 0    | 0    | # mysql07_mysql08 | es-hot09-ns3012077             |
| ftpback-rbx4-99.ovh.net:/export/ftpbackup/ns3012077.ip-5-39-68.eu/log      | /backup/log/node4  | nfs  | nolock  | 0    | 0    | # mysql07_mysql08 | es-hot09-ns3012077             |
| ftpback-rbx4-34.ovh.net:/export/ftpbackup/ns3014594.ip-178-33-227.eu/data  | /backup/data/node1 | nfs  | nolock  | 0    | 0    | # mysql15_mysql16 | mysql15                        |
| ftpback-rbx4-34.ovh.net:/export/ftpbackup/ns3014594.ip-178-33-227.eu/log   | /backup/log/node1  | nfs  | nolock  | 0    | 0    | # mysql15_mysql16 | mysql15                        |
| ftpback-rbx2-57.ovh.net:/export/ftpbackup/ns3014595.ip-178-33-226.eu/data  | /backup/data/node2 | nfs  | nolock  | 0    | 0    | # mysql15_mysql16 | mysql16                        |
| ftpback-rbx2-57.ovh.net:/export/ftpbackup/ns3014595.ip-178-33-226.eu/log   | /backup/log/node2  | nfs  | nolock  | 0    | 0    | # mysql15_mysql16 | mysql16                        |
| ftpback-rbx3-324.ovh.net:/export/ftpbackup/ns3050371.ip-5-39-69.eu/data    | /backup/data/node3 | nfs  | nolock  | 0    | 0    | # mysql15_mysql16 | es-hot10-ns3050371             |
| ftpback-rbx3-324.ovh.net:/export/ftpbackup/ns3050371.ip-5-39-69.eu/log     | /backup/log/node3  | nfs  | nolock  | 0    | 0    | # mysql15_mysql16 | es-hot10-ns3050371             |
| ftpback-rbx3-169.ovh.net:/export/ftpbackup/ns3115415.ip-5-39-75.eu/data    | /backup/data/node4 | nfs  | nolock  | 0    | 0    | # mysql15_mysql16 | es-hot11-ns3115415             |
| ftpback-rbx3-169.ovh.net:/export/ftpbackup/ns3115415.ip-5-39-75.eu/log     | /backup/log/node4  | nfs  | nolock  | 0    | 0    | # mysql15_mysql16 | es-hot11-ns3115415             |
| ftpback-rbx3-293.ovh.net:/export/ftpbackup/ns3033877.ip-51-255-71.eu/data  | /backup/data/node1 | nfs  | nolock  | 0    | 0    | # mysql21_mysql22 | mysql21                        |
| ftpback-rbx3-293.ovh.net:/export/ftpbackup/ns3033877.ip-51-255-71.eu/log   | /backup/log/node1  | nfs  | nolock  | 0    | 0    | # mysql21_mysql22 | mysql21                        |
| ftpback-rbx4-69.ovh.net:/export/ftpbackup/ns3037737.ip-46-105-105.eu/data  | /backup/data/node2 | nfs  | nolock  | 0    | 0    | # mysql21_mysql22 | mysql22                        |
| ftpback-rbx4-69.ovh.net:/export/ftpbackup/ns3037737.ip-46-105-105.eu/log   | /backup/log/node2  | nfs  | nolock  | 0    | 0    | # mysql21_mysql22 | mysql22                        |
| ftpback-rbx3-583.ovh.net:/export/ftpbackup/ns3115418.ip-5-39-69.eu/data    | /backup/data/node3 | nfs  | nolock  | 0    | 0    | # mysql21_mysql22 | es-hot12-ns3115418             |
| ftpback-rbx3-583.ovh.net:/export/ftpbackup/ns3115418.ip-5-39-69.eu/log     | /backup/log/node3  | nfs  | nolock  | 0    | 0    | # mysql21_mysql22 | es-hot12-ns3115418             |
| ftpback-rbx2-97.ovh.net:/export/ftpbackup/ns3115430.ip-5-39-69.eu/data     | /backup/data/node4 | nfs  | nolock  | 0    | 0    | # mysql21_mysql22 | es-hot13-ns3115430             |
| ftpback-rbx2-97.ovh.net:/export/ftpbackup/ns3115430.ip-5-39-69.eu/log      | /backup/log/node4  | nfs  | nolock  | 0    | 0    | # mysql21_mysql22 | es-hot13-ns3115430             |
| ftpback-rbx2-118.ovh.net:/export/ftpbackup/ns3005585.ip-46-105-114.eu/data | /backup/data/node1 | nfs  | nolock  | 0    | 0    | # mysql09_mysql10 | mysql09-ns3005585              |
| ftpback-rbx2-118.ovh.net:/export/ftpbackup/ns3005585.ip-46-105-114.eu/log  | /backup/log/node1  | nfs  | nolock  | 0    | 0    | # mysql09_mysql10 | mysql09-ns3005585              |
| ftpback-rbx3-359.ovh.net:/export/ftpbackup/ns3038403.ip-5-39-72.eu/data    | /backup/data/node2 | nfs  | nolock  | 0    | 0    | # mysql09_mysql10 | mysql10-ns3038403              |
| ftpback-rbx3-359.ovh.net:/export/ftpbackup/ns3038403.ip-5-39-72.eu/log     | /backup/log/node2  | nfs  | nolock  | 0    | 0    | # mysql09_mysql10 | mysql10-ns3038403              |
| ftpback-rbx3-144.ovh.net:/export/ftpbackup/ns3115420.ip-5-39-73.eu/data    | /backup/data/node3 | nfs  | nolock  | 0    | 0    | # mysql09_mysql10 | es-hot03-ns3071788             |
| ftpback-rbx3-144.ovh.net:/export/ftpbackup/ns3115420.ip-5-39-73.eu/log     | /backup/log/node3  | nfs  | nolock  | 0    | 0    | # mysql09_mysql10 | es-hot03-ns3071788             |
| ftpback-rbx2-20.ovh.net:/export/ftpbackup/ns3071788.ip-5-39-75.eu/data     | /backup/data/node4 | nfs  | nolock  | 0    | 0    | # mysql09_mysql10 | es-hot04-ns3115420             |
| ftpback-rbx2-20.ovh.net:/export/ftpbackup/ns3071788.ip-5-39-75.eu/log      | /backup/log/node4  | nfs  | nolock  | 0    | 0    | # mysql09_mysql10 | es-hot04-ns3115420             |

