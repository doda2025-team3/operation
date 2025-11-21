# Operation repository for SMS Checker

This repository contains all the information required to run the SMS Checker application and operate the cluster with Docker Compose.

For reference, the following repositories app (https://github.com/doda2025-team3/app/tree/A1) and model-service (https://github.com/doda2025-team3/model-service/tree/A1) contain the frontend and the backend of the application respectively. Additionally, a version aware Maven library is included in the the lib-version repository (https://github.com/doda2025-team3/lib-version/tree/A1)

## Requirements

In order to run the application, certain requirements need to be met. The following products need to be installed - **Docker** and **Docker Compose**.

## Loading the model

The application expects the model to either be inside the model volume mount or at the link specified by the MODEL_URL variable. An example link to the v1.0.0 model has been put in a .env file.

## Starting the application

To start the application, run the following command in the terminal:

```bash
docker compose up --pull always
```

In this case, it will run the latest version of the image. However, if required, specifying the variable is possible by adding the following variable specification 'TAG_VERSION=version' to the beginning. For example:

```bash
TAG_VERSION=0.0.1 docker compose up --pull always
```

Once you want to stop everything, this can easily be achieved by running the command:

```bash
docker compose down
```

