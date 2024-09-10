pipeline {
    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        booleanParam(name: 'destroy', defaultValue: false, description: 'Destroy resources instead of applying the plan?')
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
                    dir("terraform") {
                        git branch: 'main', url: 'https://github.com/SUDHA1943/Terraform-Jenkins.git'
                    }
                }
            }
        }
        stage('Cleanup') {
            steps {
                script {
                    dir('terraform') {
                        sh 'rm -f terraform.tfstate terraform.tfstate.backup'
                        sh 'rm -f *.tfplan'
                        sh 'rm -rf .terraform'
                    }
                }
            }
        }
        stage('Plan') {
            steps {
                sh 'pwd;cd terraform/ ; terraform init'
                sh "pwd;cd terraform/ ; terraform plan -out tfplan"
                sh 'pwd;cd terraform/ ; terraform show -no-color tfplan > tfplan.txt'
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
                    input message: "Do you want to apply the plan?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }
        stage('Apply') {
            when {
                not {
                    equals expected: true, actual: params.destroy
                }
            }
            steps {
                sh "pwd;cd terraform/ ; terraform apply -input=false tfplan"
            }
        }
        stage('Destroy') {
            when {
                equals expected: true, actual: params.destroy
            }
            steps {
                script {
                    def plan = readFile 'terraform/tfplan.txt'
                    input message: "Are you sure you want to destroy the resources?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
                sh "pwd;cd terraform/ ; terraform destroy -input=false -auto-approve"
            }
        }
    }
}
