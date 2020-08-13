#echo 'Deploying to' $1
#cmd='docker run -p 80:5000 -d '$2'/caprojectapp '$3';echo $?'
#echo $cmd
#ssh -i ~/testkey ubuntu@$1 $cmd

cmd='docker-compose down'
cmd='docker-compose up -d'