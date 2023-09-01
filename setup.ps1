# initialize git and set main as default branch
git init
git branch -m master main
git fetch origin
git branch -u origin/main main
git remote set-head origin -a

git remote add origin https://github.com/BenkoTIPS/cph23.git

# create .net core web app using Razor Pages
dotnet new webapp -o code/cph23

# add code
dotnet new sln
dotnet sln add code/cph23 


# PowerShell Terminal
az login
az account set --subscription fy23-devdad-sandbox  

# az ad sp create-for-rbac --name "cph23-demos-SPN" --sdk-auth

$appName = "cph23"
$rg = "cph23-arm-rg"

az group create --name $rg --location centralus

az deployment group create --resource-group $rg --template-file ./infra/arm/mySite.json --parameters appName=$appName

# Build & Deploy the code
cd ndcWeb
az webapp up -g $rg --name $appName-arm-site --plan $appName-arm-plan --os-type linux --launch-browser
cd ..

# Bicep
az bicep decompile -f ./infra/arm/mySite.json

az deployment sub create --location centralus --template-file ./infra/arm/main.bicep 


# Terraform
cd infra/TF
terraform init
terraform plan -out myPlan.plan
terraform apply myPlan.plan
terraform destroy

cd ../..

# Pulumi
cd infra
mkdir Pulumi
cd Pulumi

pulumi new azure-csharp
pulumi up
pulumi down

cd ..

# Install Ansible on WSL
sudo apt-get update
sudo apt-get install python-pip git libffi-dev libssl-dev -y
apt install python3-pip
pip install ansible pywinrm
ansible-galaxy collection install azure.azcollection
pip3 install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements-azure.txt

az ad sp create-for-rbac myAnsibleSPN

cd infra/ansible
# Set Env with setEnv.ps1

ansible-playbook webApp.yml

# Cleanup 
az group delete --name cph23-arm-rg
az group delete --name cph23-bicep-rg
pulumi down
terraform destroy
az group delete --name cph23-ansible-rg