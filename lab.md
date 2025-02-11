# Hands on lab

## Initial deployment

1. Ensure you are using a posix shell (bash, zsh, etc. in Linux, macOS, or WSL). You can also using Cloud Shell in the Azure Portal.

1. Ensure you have Azure CLI and Azure Developer CLI (AzD) installed.

1. Use AzD to deploy the lab resources:

    ```bash
    azd up
    ```

## Labs

### 1. Managed identity

In the `1-image-pull` directory, you will find a simple ACA app that pulls an image from Azure Container Registry (ACR). The app is configured to use its system-assigned managed identity to authenticate with ACR. You can try deploying it to the lab ACA environment:

```bash
az deployment group create -f 1-image-pull/app1.bicep -g $RESOURCE_GROUP_NAME
```

However, you'll notice it fails (if it results in a deployment that runs forever, delete the app before proceeding). Fix the Bicep file and try again.

### 2.

### 3. Scaling

In the Azure portal, browse to the resource group you deployed to in this lab. Find the app named `app3`. This app processes messages from a Service Bus queue and has a scale rule configured to scale based on the number of messages in the queue.

Click on the `Scale` blade and notice that the app is configured to scale to 0 when there are no messages in the queue, but it's scaled to 1. And if you add messages to the Service Bus queue, the app doesn't scale out to process them.

Figure out them problem and fix it.

### 4. Networking