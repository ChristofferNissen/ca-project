pipeline {
  agent any
  environment {
    docker_username='stifstof'
    test_server='192.168.1.101'
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
              sh 'docker-compose -f docker-compose.test.yml up --build'

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
        sshagent (credentials: ['bedtime']) {
          sh 'ssh -o StrictHostKeyChecking=no pi@192.168.1.102 ./Docker_scripts/deploy.sh'
        }
        //sh 'Docker_scripts/deploy.sh'
        //sh 'Docker_scripts/deploy.sh $test_server $docker_username'
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
