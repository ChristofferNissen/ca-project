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

    stage('build docker') {
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
          sh 'sudo pip install requests'
          sh 'python -m pip install -r requirements.txt'
          sh 'python tests.py'
          
          testResults = sh 'Docker_scripts/run.sh $docker_username tests.py'
          echo 'Docker exit code: $testResults'
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
        sh 'Docker_scripts/deploy.sh $test_server $docker_username'
      }
    }

    stage('Integration test') {
      options {
        skipDefaultCheckout()
      }
      when { branch "jenkins" }
      steps {
        // CURL test server
        sh 'curl '
      }
    }

  }
}
