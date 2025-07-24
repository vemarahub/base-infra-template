name: 'Deploy Self-Hosted Runner'

on:
  workflow_dispatch:
    inputs:
      project_name:
        description: 'Project name for the runner'
        required: true
        default: 'github-runner'
      aws_region:
        description: 'AWS region to deploy runner'
        required: true
        default: 'us-east-1'
        type: choice
        options:
          - us-east-1
          - us-west-2
          - eu-west-1
          - ap-southeast-1
      instance_type:
        description: 'EC2 instance type'
        required: true
        default: 't2.micro'
        type: choice
        options:
          - t2.micro
          - t2.small
          - t2.medium
          - t3.micro
          - t3.small
      auto_approve:
        description: 'Auto-approve terraform apply (skip confirmation)'
        required: false
        default: false
        type: boolean

env:
  AWS_REGION: ${{ github.event.inputs.aws_region }}

jobs:
  deploy-runner:
    name: 'Deploy Runner Infrastructure'
    runs-on: ubuntu-latest  # This runs on GitHub's runners to deploy your self-hosted runner
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: '1.6.0'

    - name: Generate SSH Key Pair
      run: |
        # Generate SSH key pair for EC2 access
        ssh-keygen -t rsa -b 4096 -f ~/.ssh/runner_key -N ""
        echo "PUBLIC_KEY=$(cat ~/.ssh/runner_key.pub)" >> $GITHUB_ENV
        
        # Save private key as output for later use
        echo "PRIVATE_KEY<<EOF" >> $GITHUB_ENV
        cat ~/.ssh/runner_key >> $GITHUB_ENV
        echo "EOF" >> $GITHUB_ENV

    - name: Initialize Terraform
      working-directory: runner-infrastructure
      run: terraform init

    - name: Terraform Plan
      working-directory: runner-infrastructure
      run: |
        terraform plan \
          -var="project_name=${{ github.event.inputs.project_name }}" \
          -var="aws_region=${{ github.event.inputs.aws_region }}" \
          -var="instance_type=${{ github.event.inputs.instance_type }}" \
          -var="github_repo=${{ github.repository }}" \
          -var="public_key=${{ env.PUBLIC_KEY }}" \
          -out=tfplan

    - name: Terraform Apply
      working-directory: runner-infrastructure
      run: |
        if [[ "${{ github.event.inputs.auto_approve }}" == "true" ]]; then
          terraform apply -auto-approve tfplan
        else
          echo "⚠️  Manual approval required. Set 'auto_approve' to true to skip confirmation."
          echo "Terraform plan is ready. To apply manually:"
          echo "1. Download the artifacts from this workflow"
          echo "2. Run: terraform apply tfplan"
          exit 1
        fi

    - name: Get Runner Information
      working-directory: runner-infrastructure
      run: |
        echo "## 🚀 Runner Deployed Successfully!" >> $GITHUB_STEP_SUMMARY
        echo "" >> $GITHUB_STEP_SUMMARY
        echo "**Instance Details:**" >> $GITHUB_STEP_SUMMARY
        
        # Get outputs with error handling
        INSTANCE_ID=$(terraform output -raw runner_instance_id 2>/dev/null || echo "Check AWS Console")
        PUBLIC_IP=$(terraform output -raw runner_public_ip 2>/dev/null || echo "Check AWS Console")
        
        echo "- Instance ID: $INSTANCE_ID" >> $GITHUB_STEP_SUMMARY
        echo "- Public IP: $PUBLIC_IP" >> $GITHUB_STEP_SUMMARY
        echo "- Instance Type: ${{ github.event.inputs.instance_type }}" >> $GITHUB_STEP_SUMMARY
        echo "- Region: ${{ github.event.inputs.aws_region }}" >> $GITHUB_STEP_SUMMARY
        echo "" >> $GITHUB_STEP_SUMMARY
        
        if [[ "$PUBLIC_IP" != "Check AWS Console" ]]; then
          echo "**SSH Access:**" >> $GITHUB_STEP_SUMMARY
          echo '```bash' >> $GITHUB_STEP_SUMMARY
          echo "ssh -i runner_key ubuntu@$PUBLIC_IP" >> $GITHUB_STEP_SUMMARY
          echo '```' >> $GITHUB_STEP_SUMMARY
        else
          echo "**SSH Access:** Check AWS Console for Public IP" >> $GITHUB_STEP_SUMMARY
        fi
        
        echo "" >> $GITHUB_STEP_SUMMARY
        echo "**Runner Status:**" >> $GITHUB_STEP_SUMMARY
        echo "The runner will appear in Settings > Actions > Runners in 2-3 minutes." >> $GITHUB_STEP_SUMMARY
        echo "" >> $GITHUB_STEP_SUMMARY
        echo "**Debug:** If runner doesn't appear, connect via AWS Session Manager and run:" >> $GITHUB_STEP_SUMMARY
        echo '```bash' >> $GITHUB_STEP_SUMMARY
        echo "sudo cat /var/log/cloud-init-output.log | tail -50" >> $GITHUB_STEP_SUMMARY
        echo '```' >> $GITHUB_STEP_SUMMARY
        echo "" >> $GITHUB_STEP_SUMMARY
        echo "**⚠️ Important:** Remember to destroy the runner when done to avoid charges:" >> $GITHUB_STEP_SUMMARY
        echo "Use the 'Destroy Self-Hosted Runner' workflow" >> $GITHUB_STEP_SUMMARY

    - name: Upload SSH Private Key
      uses: actions/upload-artifact@v4
      with:
        name: runner-ssh-key-${{ github.event.inputs.project_name }}
        path: ~/.ssh/runner_key
        retention-days: 7

    - name: Upload Terraform State
      uses: actions/upload-artifact@v4
      with:
        name: terraform-state-${{ github.event.inputs.project_name }}
        path: runner-infrastructure/terraform.tfstate*
        retention-days: 30
