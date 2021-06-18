scp -i ./id_rsa.by ../web/lib/* ubuntu@146.56.234.157:~/SimpleWeb/web/lib/
scp -i ./id_rsa.by ../web/service/* ubuntu@146.56.234.157:~/SimpleWeb/web/service/
scp -i ./id_rsa.by ../web/data/* ubuntu@146.56.234.157:~/SimpleWeb/web/data/
scp -i ./id_rsa.by ../config/* ubuntu@146.56.234.157:~/SimpleWeb/config/
ssh -i ./id_rsa.by ubuntu@146.56.234.157 "~/web_shell/restart.sh"