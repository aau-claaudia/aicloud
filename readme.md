SLURM experiments

This project is about getting up and running with a SLURM cluster as quickly as possible to make a base for further experiments.

It requires a Digital Ocean account, which Terraform uses to set up the infrastructure. A few Ansible roles take over the provisioning and leave you with a straightforward SLURM cluster.

## Getting started

### Preparations

First off, make sure you have `ansible-playbook` and `terraform` available in your path.

Then, there are some environment variables that need attention. I usually create a `.env` file, and put them in there, have a look at my example:

```
$ cat .env
declare -x DO_PAT="<digital ocean private access token>"
declare -x DO_KEYNAME="<digital ocean nickname of the ssh key which should be used>"
declare -x TF_LOG=ERROR
```
Before working on the project, source this file using `source .env` .

### Infrastructure

First, terraform needs to fetch some dependencies. Use `init` for this:

```
cd infrastructure/
terraform init
```

Once succedded, run apply:

```
terraform apply \
	-var "do_token=${DO_PAT}" \
	-var "do_keyname=${DO_KEYNAME}"
```

Now you should have 3 execute nodes (slurmd instances) and one controller (slurmctld instance) and terraform should have created an `inventory` file for ansible to use.

### Configuring

Move to the `ansible/` directory, and run `ansible-playbook` 
```
ansible-playbook -i inventory slurm.yml`
```
Hopefully, this was it :)

## Tearing down

Use terraform to destroy the cluster once finished tinkering:

```
terraform destroy \
	-var "do_token=${DO_PAT}" \
	-var "do_keyname=${DO_KEYNAME}"
```
