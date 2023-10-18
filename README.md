# sma ci/cd workflow
Hi Fru, This CI/CD workflow will be the conjunction of Github Action and ArgoCD.

The CI Part will be managed by GA and CD part will be managed by ArgoCD in a GITOPS way.

We will create the image of angular frontend and laravel backend service and move the containers image to digital ocean container registry. We will also tag the container image with commit hash so that we can deploy that tagged image in the kubernetes cluster via deployment.yamk file with the help of ArgoCD.

In Terms of monitoring the application we will use grafana and some other opensource tools

For scaling application we will use cluster autoscaler and node autoscaler.

We will also do a load testing so that we will have the metrics to understand what is the stress limit of our application.
