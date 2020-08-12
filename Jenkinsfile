pipeline {
  agent any
  environment {
    docker_username='stifstof'
    '?'='0'
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

    stage('Build Docker') {
      options {
        skipDefaultCheckout()
      }
      steps {
        unstash 'code'
        sh 'pwd'
        sh 'Docker_scripts/build.sh $docker_username'
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
          sh 'ls -lah'
          unstash 'code'
          sh 'ls -lah'
          sh 'sudo apt-get install python-pip -y'
          sh 'python -m pip install -r requirements.txt'
          sh 'python tests.py'
          
          sh 'Docker_scripts/run.sh tests.py $docker_username'
          echo 'Docker exit code: $?'
        }
    }

    stage('Deploy') {
      options {
        skipDefaultCheckout()
      }
      environment {
        DOCKERCREDS = credentials('docker_login') //use the credentials just created in this stage
      }
      when { branch "master" } 
      steps {
        //unstash 'build' //unstash the repository code
        //sh 'ci/build-docker.sh'
        //sh 'Docker_scripts/build.sh' $docker_username
        sh 'echo "$DOCKERCREDS_PSW" | docker login -u "$DOCKERCREDS_USR" --password-stdin' //login to docker hub with the credentials above
        sh 'Docker_scripts/push.sh $docker_username'
        //sh 'ci/push-docker.sh'
      }

    }

  }
}
