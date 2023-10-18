name: Sample Workflow

on: workflow_dispatch

jobs:
  build:
    name: Building and Pushing the Image
    runs-on: ubuntu-latest

    env:
      DOCKERFILE_PATH: ${{ github.event.inputs.dockerfile-path || './Dockerfile' }}

    steps:
    - name: Checkout
      uses: actions/checkout@v2
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ca-central-1
    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1
    - name: Determine git hash
      id: git-hash
      run: |
        git_hash=$(git rev-parse --short=7 "$GITHUB_SHA")
        echo "::set-output name=hash::$git_hash"

   

    - name: Build and push Docker image to Amazon ECR
     
      id: build-image
      env:
         ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
         ECR_REPOSITORY: iam-service
      run: |
        git_hash=${{ steps.git-hash.outputs.hash }}
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$git_hash .
         echo "Pushing image to ECR..."
         docker push $ECR_REGISTRY/$ECR_REPOSITORY:$git_hash
         echo "::set-output name=image::$ECR_REGISTRY/$ECR_REPOSITORY:$git_hash"
         echo "Docker image built and pushed successfully"
         docker images

    - name: Checkout Kubectl Object File
  
      uses: actions/checkout@v3
      with:
        repository: smagency/IAC-k8s
        token: ${{ secrets.TOKEN2 }}
        path: IAC-k8s

    - name: Update image tag in deployment YAML
      
      run: |
        git_hash=$(git rev-parse --short "$GITHUB_SHA")
        yq -i '(.spec | select(.template).template.spec.containers[] | select(.name == "laravel-service") | .image) |= "'${{ steps.build-image.outputs.image }}'"' ./IAC-k8s/k8s-yaml/sample/laravel-services/deployment.prod.yaml

    - name: Push Project B
   
      run: |
        cd ./IAC-k8s
        git add .
        git config user.name github-actions
        git config user.email github-actions@github.com
        git commit -am "K8s object file updated"
        git push
