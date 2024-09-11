pipeline {
    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        booleanParam(name: 'destroy', defaultValue: false, description: 'Destroy resources instead of creating them?')
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
                    // Clone the Git repository containing Terraform code
                    dir("terraform") {
                        git branch: 'main', url: 'https://github.com/SUDHA1943/Terraform-Jenkins.git'
                    }
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                script {
                    // Remove any existing Terraform state or plan files
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
                script {
                    // Initialize Terraform and create a plan
                    def terraformDir = 'terraform/'
                    sh "cd ${terraformDir} && terraform init"
                    sh "cd ${terraformDir} && terraform plan -out=tfplan"
                    sh "cd ${terraformDir} && terraform show -no-color tfplan > tfplan.txt"
                }
            }
        }
        
        stage('Approval') {
            when {
                // Ask for manual approval if autoApprove is not enabled
                not {
                    equals expected: true, actual: params.autoApprove
                }
            }
            steps {
                script {
                    // Show the plan and ask for confirmation to proceed
                    def plan = readFile 'terraform/tfplan.txt'
                    input message: "Do you want to apply the plan?",
                          parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }
        
        stage('Apply') {
            when {
                // Only apply the plan if we're not in destroy mode
                expression {
                    return !params.destroy
                }
            }
            steps {
                script {
                    // Apply the Terraform plan to create resources
                    sh "cd terraform/ && terraform apply -input=false tfplan"
                }
            }
        }

        stage('Destroy') {
            when {
                // Only destroy resources if the destroy checkbox is selected
                expression {
                    return params.destroy
                }
            }
            steps {
                script {
                    // Destroy the Terraform-managed resources
                    sh "cd terraform/ && terraform destroy -input=false -auto-approve"
                }
            }
        }
    }
}
