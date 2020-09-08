pipeline {
  agent {
    label 'arm'
  }
  environment {
    docker_username='stifstof'
    test_server='91.100.23.100'
  }

  stages {

    stage('clone down') {
      steps {
        stash name: 'code', excludes: '.git'
      }
      post {
        always {
          sh 'ls -lah'
          deleteDir()
          sh 'ls -lah'
        }
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
          
        }

        stage('Test') {
          options {
            skipDefaultCheckout()
          }
          steps {
            unstash 'code'
            echo 'Pipeline will fail if docker tests returns non-zero exit status'
            sh 'docker-compose -f docker-compose.test.yml up --build'
            sh 'echo $?'
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
        unstash 'code' //unstash the repository code
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
	      unstash 'code'
	      sh 'ls -lah'
        sshagent (credentials: ['bedtime']) {
          sh ''' 
            NANOSEC=$(date +%N) 
            scp -r -o StrictHostKeyChecking=no $WORKSPACE pi@192.168.1.102:~/jenkins-agent-deploy-artifacts/$NANOSEC
            ssh -o StrictHostKeyChecking=no pi@192.168.1.102 ./jenkins-agent-deploy-artifacts/$NANOSEC/Docker_scripts/deploy.sh
            ssh -o StrictHostKeyChecking=no pi@192.168.1.102 rm -r ./jenkins-agent-deploy-artifacts/$NANOSEC/
          '''
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
