pipeline {
  agent any
    
  tools {
    nodejs "node"
    }
    
  stages {
    
   stage('Build') {
      steps {
        sh 'npm install'
      }
    }  

   stage('Run') {
      steps {
        sh 'sudo docker-compose  up -d'
      }
    }

    stage('Test') {
      steps {
        sh 'npm test'
      }
    }

  }
}

