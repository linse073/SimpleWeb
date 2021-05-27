ssh -i ../id_rsa.by ubuntu@146.56.234.157 "[ ! -d web_shell ] && mkdir -p web_shell"
scp -i ../id_rsa.by ./*.sh ubuntu@146.56.234.157:~/web_shell
ssh -i ../id_rsa.by ubuntu@146.56.234.157 "find . -name "*.sh" | xargs chmod a+x"
pause