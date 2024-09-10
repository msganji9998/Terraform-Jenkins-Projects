pipeline {
    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    } 
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
    agent any
    stages {
        stage('Checkout') {
            steps {
                script {
                    dir('terraform') {
                        git 'https://github.com/SUDHA1943/Terraform-Jenkins.git'
                    }
                }
            }
        }
        stage('Cleanup') {
            steps {
                script {
                    // Navigate to the Terraform directory
                    dir('terraform') {
                        // Remove old state and backup files
                        sh 'rm -f terraform.tfstate terraform.tfstate.backup'
                        // Remove old plan files
                        sh 'rm -f *.tfplan'
                        // Remove the .terraform directory if it exists
                        sh 'rm -rf .terraform'
                    }
                }
            }
        }
        stage('Plan') {
            steps {
                script {
                    dir('terraform') {
                        sh 'terraform init'
                        sh 'terraform plan -out=tfplan'
                        sh 'terraform show -no-color tfplan > tfplan.txt'
                    }
                }
            }
        }
        stage('Approval') {
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
            }
            steps {
                script {
                    def plan = readFile 'terraform/tfplan.txt'
                    input message: 'Do you want to apply the plan?', parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }
        stage('Apply') {
            steps {
                script {
                    dir('terraform') {
                        sh 'terraform apply -input=false tfplan'
                    }
                }
            }
        }
    }
}
