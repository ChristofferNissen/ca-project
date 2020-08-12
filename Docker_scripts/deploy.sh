echo 'Deploying to' $1
cmd='docker run -d '$2'/caprojectapp '$3';echo $?'
echo $cmd
ssh -i ~/testkey ubuntu@$1 $cmd