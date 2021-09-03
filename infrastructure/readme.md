# digital ocean infrastructure
For experimentation and somewhat unmaintained as we moved towards our own hardware

There are some environment variables that need attention. I usually create a `.env` file, and put them in there, have a look at my example:

```
$ cat .env
declare -x DO_PAT="<digital ocean private access token>"
declare -x DO_KEYNAME="<digital ocean nickname of the ssh key which should be used>"
declare -x TF_LOG=ERROR
```
Before working on the project, source this file using `source .env` .

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

Now you should have 3 execute nodes (slurmd instances) and one controller (slurmctld instance) and terraform should have created an `../ansible/terraform-inventory` file for ansible to use.


Use terraform to destroy the cluster once finished tinkering:

```
terraform destroy \
	-var "do_token=${DO_PAT}" \
	-var "do_keyname=${DO_KEYNAME}"
```
