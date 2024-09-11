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
                    sh 'terraform plan -out=tfplan'
                    sh 'terraform show -no-color tfplan > tfplan.txt'
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
                    input message: "Do you want to apply the plan?",
                        parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }

        stage('Destroy') {
            when {
                expression { params.destroy }
            }
            steps {
                dir('terraform') {
                    script {
                        if (params.autoApprove) {
                            sh 'terraform destroy -auto-approve'
                        } else {
                            sh 'terraform plan -destroy -out=tfplan-destroy'
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

        stage('Apply') {
            when {
                not {
                    expression { params.destroy }
                }
            }
            steps {
                dir('terraform') {
                    script {
                        if (params.autoApprove) {
                            sh 'terraform apply -input=false tfplan'
                        } else {
                            sh 'terraform show -no-color tfplan > tfplan.txt'
                            def applyPlan = readFile 'terraform/tfplan.txt'
                            input message: "Do you want to apply the plan?",
                                parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: applyPlan)]
                            sh 'terraform apply -input=false tfplan'
                        }
                    }
                }
            }
        }
    }
}
