alias rebuilddb='bash /vagrant/scripts/rebuilddb.sh'
alias logs='tail -f /var/log/apache2/*'
alias dumpdb='mysqldump -u root -proot --skip-comments --complete-insert scotchbox | sed -e "s/),(/),\n(/g" -e "s/VALUES\s(/VALUES\n(/g" > /vagrant/scripts/dump.sql'
