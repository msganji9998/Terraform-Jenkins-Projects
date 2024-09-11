pipeline {
    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        booleanParam(name: 'destroy', defaultValue: false, description: 'Destroy the infrastructure instead of applying changes?')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    agent any

    stages {
        stage('Checkout') {
            steps {
                dir('terraform') {
                    git branch: 'main', url: 'https://github.com/SUDHA1943/Terraform-Jenkins.git'
                }
            }
        }

        stage('Cleanup') {
            steps {
                dir('terraform') {
                    sh 'rm -f terraform.tfstate terraform.tfstate.backup'
                    sh 'rm -f *.tfplan'
                    sh 'rm -rf .terraform'
                }
            }
        }

        stage('Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    if (params.destroy) {
                        sh 'terraform plan -destroy -out=tfplan-destroy'
                        sh 'terraform show -no-color tfplan-destroy > tfplan-destroy.txt'
                    } else {
                        sh 'terraform plan -out=tfplan'
                        sh 'terraform show -no-color tfplan > tfplan.txt'
                    }
                }
            }
        }

        stage('Approval') {
            when {
                anyOf {
                    expression { params.autoApprove == false && !params.destroy }
                    expression { params.autoApprove == false && params.destroy }
                }
            }
            steps {
                script {
                    def planFile = params.destroy ? 'terraform/tfplan-destroy.txt' : 'terraform/tfplan.txt'
                    def plan = readFile(planFile)
                    input message: "Do you want to proceed with the plan?",
                        parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }

        stage('Apply') {
            when {
                expression { !params.destroy }
            }
            steps {
                dir('terraform') {
                    if (params.autoApprove) {
                        sh 'terraform apply -input=false tfplan'
                    } else {
                        sh 'terraform apply -input=false tfplan'
                    }
                }
            }
        }

        stage('Destroy') {
            when {
                expression { params.destroy }
            }
            steps {
                dir('terraform') {
                    if (params.autoApprove) {
                        sh 'terraform destroy -auto-approve'
                    } else {
                        sh 'terraform destroy -out=tfplan-destroy'
                        sh 'terraform show -no-color tfplan-destroy > tfplan-destroy.txt'
                        def destroyPlan = readFile 'terraform/tfplan-destroy.txt'
                        input message: "Do you want to destroy the infrastructure?",
                            parameters: [text(name: 'Destroy Plan', description: 'Please review the destroy plan', defaultValue: destroyPlan)]
                        sh 'terraform destroy -input=false -auto-approve'
                    }
                }
            }
        }
    }
}
