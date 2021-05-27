scp -i ./id_rsa.by ../web/lib/* ubuntu@146.56.234.157:~/SimpleWeb/web/lib/
scp -i ./id_rsa.by ../web/service/* ubuntu@146.56.234.157:~/SimpleWeb/web/service/
ssh -i ./id_rsa.by ubuntu@146.56.234.157 "~/web_shell/restart.sh"