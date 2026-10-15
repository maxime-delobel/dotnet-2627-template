pipeline {
  agent any
  stages {
    stage('Build and deploy') {
      steps {
        sh '''
          set -e
          APP=vagrant@192.168.100.2
          KEY=/var/lib/jenkins/keys/prod_ssh_key
          SSH_OPTS="-i $KEY -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=accept-new"

          rm -rf publish rise-server.tar.gz
          dotnet publish src/Rise.Server -c Release -o publish
          tar czf rise-server.tar.gz -C publish .

          scp $SSH_OPTS rise-server.tar.gz $APP:/tmp/
          ssh $SSH_OPTS $APP '
            set -e
            sudo rm -rf /opt/rise-server/*
            sudo tar xzf /tmp/rise-server.tar.gz -C /opt/rise-server
            sudo chown -R deploy:deploy /opt/rise-server
            sudo systemctl restart rise-server

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
