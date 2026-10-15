pipeline {
  agent any

  environment {
    APP      = 'vagrant@192.168.100.2'
    KEY      = '/var/lib/jenkins/keys/prod_ssh_key'
    SSH_OPTS = "-i ${KEY} -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=accept-new"
  }

  stages {
    stage('Build') {
      steps {
        sh '''
          set -e
          rm -rf publish rise-server.tar.gz
          dotnet publish src/Rise.Server -c Release -o publish
        '''
      }
    }

    stage('Package') {
      steps {
        sh '''
          set -e
          tar czf rise-server.tar.gz -C publish .
        '''
      }
    }

    stage('Upload') {
      steps {
        sh '''
          set -e
          scp $SSH_OPTS rise-server.tar.gz $APP:/tmp/
        '''
      }
    }

    stage('Deploy') {
      steps {
        sh '''
          set -e
          ssh $SSH_OPTS $APP '
            set -e
            sudo rm -rf /opt/rise-server/*
            sudo tar xzf /tmp/rise-server.tar.gz -C /opt/rise-server
            sudo chown -R deploy:deploy /opt/rise-server
            sudo systemctl restart rise-server
          '
        '''
      }
    }

    stage('Health check') {
      steps {
        sh '''
          set -e
          ssh $SSH_OPTS $APP '
            for i in $(seq 1 15); do
              if curl -s -o /dev/null http://localhost:80/; then
                echo "App is up"
                exit 0
              fi
              sleep 2
            done

            echo "App did not come up. Last logs:"
            sudo journalctl -u rise-server -n 30 --no-pager
            exit 1
          '
        '''
      }
    }
  }
}
