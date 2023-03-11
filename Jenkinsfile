pipeline {
  parameters {
        choice name: 'NAMESPACE', choices: ['dxl-pre-cz','dxl-sys-cz','dxl-dev-cz','dxl-int-cz'], description: 'cluster namespace' $1
        string name: 'DATABASE_NAME', description: 'database name.', trim: true $2
        string name: 'COL_NAME', description: 'collection name.', trim: true $3
    }
  
    agent {
        kubernetes {
            yaml '''
            apiVersion: v1
            kind: Pod
            metadata:
                labels:
                    jenkins: slave
                    jenkins/docker: 'true'
            spec:
                activeDeadlineSeconds: 1800
                containers:
                -
                    name: helm
                    image: 728642754198.dkr.ecr.eu-central-1.amazonaws.com/dxl-cz-ci-helm:3.9.4
                    command:
                        - cat
                    tty: true
            '''
        }
    }
  stages {
    stage('Deploy') {
      steps {
                container('helm') {
                    withCredentials([file(credentialsId: 'jenkins-deployer-dev-cz', variable: 'kubeconfig')]) { 
                      
                        cluster_name = "${params.NAMESPACE}"
                        database_name = "${params.DATABASE_NAME}"
                        namespace = 'dxl-pre-cz'
                        col_name = "${params.COL_NAME}"

                      
                      bash total.sh  ${cluster_name} ${database_name} ${namespace} ${col_name}
          }
        }
      }
    }
  }
}
