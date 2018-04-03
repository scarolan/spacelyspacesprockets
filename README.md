# Spacely Space Sprockets - a Terraform Enterprise Demo
Hashicorp Infrastructure Automation Demos

## Prerequisites

There are two demo environments you can build.  They can be run together at the same time, or separately from one another.  The first demo shows off Terraform and Packer.  The second demo highlights Consul and Vault.

`terraform_demo` stands up three instances of a simple home page behind a load balancer with an optional DNS name.  The demo begins with a single instance and security group.  You can then uncomment the rest of the `demo_ecommerce.tf` file to show your audience how easy it is to build more infrastructure with Terraform.  The application stack in this part of the demo has been stripped down to a simple web server for speed of deployment.

`full_demo` stands up the same as above but adds Consul and Vault into the mix, and gets you the full Linux/MySQL/Java+Tomcat/Apache stack on each app server.  This is ideal for more in-depth demos or development work.

For the terraform demo just follow the first four steps below.  For the full demo, follow all the steps.

## Terraform and Packer Demo
0. Create a new VPC with three subnets.  This demo has been tested in us-east-2.
1. Edit the run\_chef.sh and run\_chef\_dev.sh scripts and add your password or token to the git clone command.  This allows you to clone down the private repo during your demo.  TODO: Store chef cookbook in S3 instead.
2. Install Terraform on your local workstation.  Set up your AWS credentials.
3. Make sure you have an IAM role called Consul, with the contents of iam_policy.json attached to it.  This is required for the Consul agents to use the AWS API to find each other.
4. Use the `terraform apply` command to provision the demo environment.
5. OPTIONAL:  Uncomment the lines at the end of demo_ecommerce.tf to enable DNS resolution.  Make sure you set up Route 53 with your domain first.

## Terraform/Consul/Vault Demo
6. Log onto each of the Vault instances via SSH.  Get into a root shell: `sudo /bin/su - root`
7. Before you run any Vault commands set up this environment variable: `export VAULT_ADDR=http://127.0.0.1:8200`.  
8. On each instance start Vault `service vault start`.
9. Go back to the first instance and type `vault init`.  Some keys will be generated for you.
10. Save your keys somewhere safe!  Next you'll unseal the vault on each of your three instances.
11. Type the magic words `vault unseal`.  Copy any of your five keys into the terminal.  Repeat two more times with a different key each time.  Afterwards, run `vault status` to verify that the vault is unsealed.  You must run `vault unseal` three times on each host!  NOTE: The first host you unseal will become the initial master host.
12. Go to the other two nodes and repeat the previous step on them.  All three vault servers should now be in an HA configuration, using consul as a storage backend.
13. Back on the first node let's create a vault.  Run `vault auth TOKEN`, replacing TOKEN with what you got in step #7.
14. Populate your vault with some data.  For the third example you'll have to copy the contents of the certificate file onto the Vault instance you're running this from.  The file is in the 'files' directory of the demo-ecommerce cookbook.

```
 vault write secret/username value=mrrobot
 vault write secret/password value=3LL107
 vault write secret/sslcert value=@/path/to/f73e89fd.0
 ```

15. Now ssh onto one of your web servers.  cd into the /tmp directory.  Edit /tmp/cookbooks/demo-ecommerce/recipes/secret.rb and enter your token and vault load balancer address into the recipe.  Run chef client like this: `chef-client -z -o demo-ecommerce::secret`.  You should see the Chef client run and populate /usr/share/tomcat/webapps/ROOT/hello.txt with the username and password.  It will also put your SSL certificate into the /usr/share/tomcat/webapps/WEB-INF/ directory.

## TO DO LIST
* Incorporate Nomad into the demo
* Expand the demo to include enterprise features
