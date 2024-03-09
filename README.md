# Project Data Engineering Zoomcamp 2024
This repository contains my final project for the Data Engineering Zoomcamp cohort 2024 taught by DataTalksClub. The course's repository can be found [here](https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main).

## Objective
The objective of the final project is to build an end-to-end data pipeline with a chosen dataset. It should contaiin the following items:
* Select a dataset
* Create a pipeline to load the data into a datalake
* Create a pipeline to move the data into a data warehouse
* Transform the data in the data warehouse
* Build a dashboard to visualize the data

## Technologies used
The following technologies will be used:
* IaC: Terraform
* Cloud: GCP
* VM: GCP Cloud VM
* Workflow orchestation: Mage
* Data Lake: Google Cloud Storage
* Data Warehouse: Google BigQuery
* Data transformation: DBT
* Visualization: Looker

## Problem description
This project will use the dataset "Mental Health Dataset", that can be found [here](https://www.kaggle.com/datasets/divaniazzahra/mental-health-dataset). This is an open source dataset found in Kaggle.

The idea is to build a data pipeline that will extract the data and prepare it for a visualization in Looker. This way we will be able to analyze patterns in mental health across time, geography, and other variables.

The project can be summarized as follows:
1. Build the needed infrastructure using Terraform
2. Ingest dataset into GCS from the given link using Mage
3. Transfer dataset from GCS to BigQuery  using Mage
4. Transform data in Bigquery using dbt
5. Visualize data in dashboard using Looker

This will be developed inside a Virtual Machine built on GCP Cloud VM

## Setup
1. Create a new project in GCP.
2. Go to IAM & Admin > Service Accounts, and create a new service account
3. Create a new json key for the service account
4. Save the key in the working directory with the name `.cred.json`

Additionally, the following must be done:
* Enable the Compute Engine API. In the Cloud Console, go to "APIs & Services" > "Library," search for "Compute Engine API," and enable it.
* Under IAM & Admin > IAM, add the following roles to the newly created service account: Viewer + Storage Admin + Storage Object Admin + BigQuery Admin + Compute Admin
* Create ssh key to connect to VM. In `~/.ssh` run 
```bash
ssh-keygen -t rsa -f ~/.ssh./KEY_FILENAME -C USERNAME -b 2046
```
Then, copy the contents of the public file and paste them in Compute Engine > Metadata > SSH Keys

## Terraform
In this part all the necessary infrastructure will be created:
* Virtual Machine in GCP Cloud VM (Optional: if you want to work with a Virtual Machine)
* GCS bucket
* Big Query dataset

Before running terraform, you must modify the file `variables.tf` to your personal details.

Run `terraform init` to initialize terraform. Then run `terraform apply` to build the infrastructure. When this is done, a virtual machine, GCS bucket and Big Query Dataset will be created in the GCP project.\
To destroy them, run `terraform destroy`.

### Optional: Virtual Machine. 
The project can be developed locally, but if you want to work in a virtual machine, this is how you can connect to one in Google Cloud VM\
After the VM is created, go to Compute Engine > VM instances and you will find the created VM. Copy the External IP, as it will be the address needed to connect to the VM.

To connect to the VM, `run ssh -i $SSH_FILEPATH $USERNAME@$EXTERNAL_IP`, where SSH_FILEPATH is the filepath of the ssh private key, USERNAME is the username used when creating the SSH key and EXTERNAL_IP is the External IP of the VM previously created.

Additionally, you can create a `config` file in `~/.ssh/`. This will look something like this:
```bash
Host de-zoomcamp-project
    HostName $EXTERNAL_IP
    user $USERNAME
    IdentityFile $SSH_FILEPATH
```

Then, you can connect to the VM by simply running `ssh de-zoomcamp-project`.

Finally, you must install docker in the newly created VM:
```bash
sudo apt-get update
sudo apt-get install wget
sudo apt-get install docker.io
```
Then, execute the following to configure Docker in the VM as shown [here](https://github.com/sindresorhus/guides/blob/main/docker-without-sudo.md).
```bash
sudo groupadd docker
sudo gpasswd -a $USER docker
sudo service docker restart
```
After these commands, log out and in of the VM and now Docker should work.

Then, create a folder called bin in your home directory in the VM and download the docker compose executable:
```bash
wget https://github.com/docker/compose/releases/download/v2.24.7/docker-compose-linux-x86_64  -O docker-compose
chmod +x docker-compose
```
Then, go to `~/.bashrc` file and add the following to the end of the file:
```bash
export PATH="${HOME}/bin:${PATH}"
```
Then, execute `source .bashrc`.

Finally, clone the current repository in the VM (it is easier to do it via HTTPS so that you don't have to configure a new ssh key in the VM)
```bash
git clone REPO_URL_HTTPS
```

## Mage
This part is needed to ingest data and save it in GCS and Big Query. 

As we will be using a Dataset from Kaggle, we must first dowload the Kaggle API user and token, so that we can download the needed data in the pipeline. To do so, go to your user profile in (Kaggle)[kaggle.com], then settings, and then, under API, click on "Create New Token". This will download a json file called `kaggle.json` with your private username and token. Save that file in the working directory of the project with the name `kaggle.json`.

Note: if you are working in the VM, you must first copy the `kaggle.json` file to the VM. This can me done with the command
```bash
scp $LOCAL_FILEPATH $USERNAME@$EXTERNAL_IP/$VM_FILEPATH
```
Where `$LOCAL_FILEPATH` is the filepath in your local machine where `kaggle.json` is, `$USERNAME` is the username used when creating the SSH key of the VM, `$EXTERNAL_IP` is the External IP of the VM previously created, and `$VM_FILEPATH` is where the file `kaggle.json` will be copied in the VM (this must be in the cloned repository on top of the `Mage` folder).

Note: if you are working in the VM, you must first copy the `.cred.json` file to the VM. This is the file that you previously saved with your GCP Service Account credentials in the [Setup](#setup) part. This can me done with the command
```bash
scp $LOCAL_FILEPATH $USERNAME@$EXTERNAL_IP/$VM_FILEPATH
```
Where `$LOCAL_FILEPATH` is the filepath in your local machine where `.cred.json` is, `$USERNAME` is the username used when creating the SSH key of the VM, `$EXTERNAL_IP` is the External IP of the VM previously created, and `$VM_FILEPATH` is where the file `.cred.json` will be copied in the VM (this must be in the cloned repository on top of the `Mage` folder).

Run `docker compose build` and then `docker compose up`. Then go to http://localhost:6789 to open Mage.

The mental_health_pipeline Pipeline is the one resposible of ingesting the data, transforming it, and loading it to GCP and Big Query as follows:

### Data Loading
The module `load_mental_health` is responsible of configuring the environment variables needed by the Kaggle API. They are read from the `kaggle.json` file and set to environment variables by doing
```python
os.environ['KAGGLE_USERNAME'] = data['username'] # username from the json file
os.environ['KAGGLE_KEY'] = data['key'] # key from the json file
```
The dataset is then read with the Kaggle API and loaded to a dataframe with correct data types.

### Data Transformation
The module `transform_mental-health` is responsible of transforming the dataset. It validates that certain important columns are not null, transforms column names to standard snake case, and eliminates duplicates.

### Data Exporting
The module `save_mental_health_gcs` is responsible of saving the dataset in a Google Cloud Storage bucket. It saves a file called `mental_health.csv` inside the bucket `mental-health-bucket`.


### Run the data pipeline
To run the data pipeline, you can go to Triggers, and then enter the `mental_health_pipeline` trigger, then click on "Run@Once". This will manually run the pipeline one time. This pipeline is programmed to run every day at 10am UTC, anyway (you just have to turn it on by setting it as Active).

## Data Warehouse in Big Query
Once the dataset is already in a bucket in GCS, we can create and external table in Google Big Query as our Data Warehouse.

To create the external table, go to Big Query and type execute
```sql
CREATE OR REPLACE EXTERNAL TABLE `$PROJECT.$DATASET.$TABLE_EXTERNAL`
OPTIONS (
  format = 'CSV',
  uris = ['gs://mental-health-bucket/mental_health.csv']
)
```
Where `$PROJECT` is the GCP project, `$DATASET` is the name of the Big Query Dataset and `$TABLE_EXTERNAL` is the name that you want to give to the external table that will be created in Big Query.

Then, execute in Big Query the following query:
```sql
CREATE OR REPLACE TABLE $PROJECT.$DATASET.$TABLE
PARTITION BY DATE(timestamp)
CLUSTER BY country AS
SELECT * EXCEPT(int64_field_0) FROM $PROJECT.$DATASET.$TABLE_EXTERNAL;
```
Where `$TABLE` is the name that you want to give to the final table that will be created in Big Query.\
This table will be created partitioned by the column timestamp (specifices the datetime of the data point), and will by clustered by the column country, as the majority of analyzis for this table will be made in terms of geographical aggregation.

## Transformations in DBT
This part is developed on DBT Cloud. The instructions to set up a DBT Cloud account and setup it with Big Query can be found (here)[https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/04-analytics-engineering/dbt_cloud_setup.md].

