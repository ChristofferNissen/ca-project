pipeline {
  agent any
  environment {
    docker_username='stifstof'
    test_server='35.195.24.192'
  }

  stages {

    stage('clone down') {
      agent {
        label 'host'
      }
      steps {
        stash name: 'code', excludes: '.git'
      }  
    }
    
    stage('Parallel Excution') {
      parallel {
        stage('build docker') {
          options {
            skipDefaultCheckout()
          }
          steps {
            unstash 'code'
            sh 'Docker_scripts/build.sh'
          }
          post {
            always {
              sh 'ls -lah'
              deleteDir()
              sh 'ls -lah'
            }
          }
        }

        stage('Test') {
            options {
              skipDefaultCheckout()
            }
            steps {
              unstash 'code'
              //sh 'sudo apt-get install python-pip -y'
              //sh 'sudo pip install requests'
              //sh 'python -m pip install -r requirements.txt'
              //sh 'python tests.py'
              
              echo 'Pipeline will fail if docker tests returns non-zero exit status'
              //sh 'Docker_scripts/run.sh $docker_username tests.py'
              sh 'docker-compose up --build --exit-code-from sut -f docker-compose.test.yml'

            }
        }

      }
    }

    

    

    stage('Push to Dockerhub') {
      options {
        skipDefaultCheckout()
      }
      environment {
        DOCKERCREDS = credentials('docker_login') //use the credentials just created in this stage
      }
      when { branch "jenkins" } 
      steps {
        //unstash 'build' //unstash the repository code
        //sh 'ci/build-docker.sh'
        //sh 'Docker_scripts/build.sh' $docker_username
        sh 'echo "$DOCKERCREDS_PSW" | docker login -u "$DOCKERCREDS_USR" --password-stdin' //login to docker hub with the credentials above
        sh 'Docker_scripts/push.sh $docker_username'
        //sh 'ci/push-docker.sh'
      }

    }

    stage('Deploy to test server'){
      options {
        skipDefaultCheckout()
      }
      when { branch "jenkins" }
      steps {
        // DEPLOY TO TEST-SERVER
        //sh 'ls -lah var/lib/jenkins/.ssh/'
        
        sh 'Docker_scripts/deploy.sh'
        //sh 'Docker_scripts/deploy.sh $test_server $docker_username'
      }
    }

    def remote = [:]
    remote.name = "host"
    remote.host = "35.195.24.192:8080"
    remote.allowAnyHosts = true
    node {
        withCredentials([sshUserPrivateKey(credentialsId: 'bedtime', keyFileVariable: 'identity', passphraseVariable: '', usernameVariable: 'userName')]) {
            remote.user = userName
            remote.identityFile = identity
            stage("SSH Steps Rocks!") {
                writeFile file: 'abc.sh', text: 'ls'
                sshCommand remote: remote, command: 'for i in {1..5}; do echo -n \"Loop \$i \"; date ; sleep 1; done'
                sshPut remote: remote, from: 'abc.sh', into: '.'
                sshGet remote: remote, from: 'abc.sh', into: 'bac.sh', override: true
                sshScript remote: remote, script: 'abc.sh'
                sshRemove remote: remote, path: 'abc.sh'
            }
        }
    }

    stage('Integration test') {
      options {
        skipDefaultCheckout()
      }
      when { branch "jenkins" }
      steps {
        // CURL test server
        sh 'curl -s -o /dev/null -w "%{http_code}" $test_server'
      }
    }

  }
}
