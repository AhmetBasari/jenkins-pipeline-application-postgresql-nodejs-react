pipeline{
    agent any
    tools{
        terraform 'terraform'
        ansible 'ansible'
        docker 'docker'
    }

    environmnet {
        MY_FILES = sh(script: "echo $MY_FILES:/usr/local/bin", returnStdout: true).trim()
        AWS_REGION = "us-east-1"
        AWS_ACCOUNT_ID = sh(returnStdout: true, script: 'aws sts get-caller-identity --query "Account" --output text').trim()
        ECR_URL="${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com"
        APP_REPO_NAME="ahmet/jenkins-todo"
    }

    stage('Terraform apply') {
        steps {
            echo 'Initializing Terraform to set up AWS infrastructure...'
            sh 'terraform init'
            echo 'Applying Terraform plan to create the necessary resources...'
            sh 'terraform apply --auto-approve'
            echo 'Infrastructure creation completed.'
    }

    stage('Create ECR Repo') {
        steps {
            echo 'Creating ECR Repo if it does not exist'
            sh '''
            aws ecr describe-repositories --region ${AWS_REGION} --repository-name ${APP_REPO_NAME} || \
            (echo 'ECR repository does not exist. Creating it now...' && \
            aws ecr create-repository \
              --repository-name ${APP_REPO_NAME} \
              --image-scanning-configuration scanOnPush=false \
              --image-tag-mutability MUTABLE \
              --region ${AWS_REGION} && \
            echo 'ECR repository created successfully.')
            '''
    }
    
}




}


}

