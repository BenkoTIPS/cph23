# PowerShell Terminal
az login
az account set --subscription fy23-devdad-sandbox  

$appName = "cph23"
$rg = "cph23-arm-rg"

# ARM

az group create --name $rg --location centralus

az deployment group create --resource-group $rg --template-file ./infra/arm/mySite.json --parameters appName=$appName


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

ansible-playbook webApp.yml

# Cleanup 
az group delete --name cph23-arm-rg
az group delete --name cph23-bicep-rg
pulumi down
terraform destroy
az group delete --name cph23-ansible-rg