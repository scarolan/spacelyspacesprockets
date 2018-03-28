# Hashicorp Product Demo

## Setup Instructions
 Go through the README.md and follow all the setup steps
 Present the demo slide deck: http://goo.gl/AqNV6Q
 Follow the dialog and instructions below:

## Act 1 - Terraform and Packer Demo

### Act 1, Scene 1 - Migrate to the cloud with Terraform

**_Open the Spacely Space Sprockets production website in a browser._**

Welcome to Spacely Space Sprockets, the world's leading manufacturer of, you guessed it, Space Sprockets.  (Is anyone old enough to remember the Jetsons?) Recently the company has begun a cloud migration so they can compete with their largest competitor, Cogswell's Cogs.  Management has given the systems engineering team a mandate to move all development environments to the cloud by the end of the month.  Our goal is to deliver development environments faster and with more efficiency, eventually allowing developers to self-provision their own environments.  We also need to remain secure and compliant with internal and external security rules.

The lead system administrator, George, has been using a combination of shell scripts and Chef recipes to build his on-premises infrastructure in a VMware vCenter cluster.  While some of the steps are automated, there are many manual steps that are recorded either in a run book or wiki page.  Deploying new machines can take anywhere from a few hours to a few days depending on the type of application stack.  Developers have complained about long wait times to get their environments provisioned and set up correctly.

George has recently started using Terraform, Hashicorp's infrastructure provisioning tool.  Terraform is easy to install and easy to use.  The download consists of a single binary file that requires no special libraries or dependencies.  You can run Terraform on Linux, Mac, or Windows operating systems.  Let's follow along with George on his journey and see how he automates the build and deployment of Spacely's development environments.

**_Open up the projectk main folder and point out that Terraform supports multiple cloud providers._**

Here we can see several different directories and files.  Each one of these cloud provider directories has specific instructions on how to build the Spacely dev environment.  

**_Open up the 'shared' folder._**

Inside this shared folder we have all of the resources that are the same across all providers.  This might include shell scripts, powershell, Chef recipes or Puppet modules.  Terraform supports them all.  Another benefit to using Terraform is that you don't have to change your build method.  Have a big pile of Powershell scripts?  Let Terraform run them for you.  Maybe you're a Chef user - we fully support Chef, Puppet and Ansible.  You can continue to build your machines the way you are used to doing it, but get the added benefits of automation and testing that come with infrastructure as code.

George has rounded up all the scripts and Chef recipes that he normally uses to build machines.  He's placed them all into the shared directory here.  Spacely management has decided to start small and move a single dev environment to AWS.  With Terraform you can build a single machine or an entire data center.

**_Open up the 'aws' folder and then go into the 'terraform_demo' folder._**

These are the Terraform plan files that are going to build our infrastructure.  Anything in this directory that ends with a .tf extension will be run.  The variables.tf file contains all of the user-tunable settings you want to expose.  By separating these variables out of the main file, we make it easy for you to re-use your Terraform plans in different environments.  The outputs.tf file makes it easy to define what kind of information you want to show when a terraform apply command is complete.  This might include the URL of your website, or any other data about your infrastruture.  Then we have the main demo_ecommerce.tf file that is actually doing all the work.  Let's take a look inside this file.

Here you can see two terraform resources at the top of the file.  One is the `aws_instance` resource, and the other is an `aws_security_group` resource.  Since George is just starting out with Terraform he's going to start small and build a single server inside a Virtual Private Cloud (VPC) in AWS.

Let's go ahead and execute this code and build our first web server.  I'm going to first run `terraform plan`.  This reads all of my \*.tf files and shows what would be built when we run `terraform apply`.  You can save the plan in an output file that can be checksummed and promoted to different environments.  In this way you know *exactly* what you will get when you build out your infrastructure. 

**_Run `terrraform plan -out myplan.tpf`_**

Now we have this plan file that we can checksum and promote into production.  Any change made to any of my tf files or variables will result in a new checksum. 

**_Run `md5 myplan.tpf`_**

 This prevents small errors or 'oopsies' from sneaking into your dev, QA, or production environments.  Because the whole thing is codified, any and all changes to infrastructure or apps can be managed and approved before promomtion.  The enterprise version of Terraform enables extra features for collaboration and governance.
 
 Using Terraform is like having an inflatable data center.  Drop your terraform plan in place, run `terraform apply myplan.tpf` and you are guaranteed to get the correct build and environment settings, every single time.

**_Run `terraform apply myplan.tpf` in the 'terraform\_demo' directory._**

While terraform builds out our server, let's take a little closer look at some of the different types of resources you can build and how they work.  First is the AWS instance resource.  This lets you create cloud instances, which are like VMs that run on Amazon's infrastructure.  Our sysadmin George is now able to focus on quickly bringing up new instances without having to go througha bunch of manual steps to get all the network, storage, compute and security settings ready.  

**_Walk through the code and explain what some of the settings in aws\_instance can do.  Explain how provisioners work and point out that you can use your existing shell scripts or Chef recipes with Terraform._**

The next resource is our AWS security group.  AWS security groups are like firewalls that run at the host level.  By default they deny all inbound traffic so we have to specify what ports we want to open up.  Note that we didn't have to define any special order of operations or dependencies.  Terraform is smart enough to know that it needs to create the security group before creating the AWS instance.  

**_Check in on the `terraform apply` command.  If it's finished, proceed, if not talk about the state file and how it works.  This is a good time to plug Terraform enterprise, which has features for collaboration and governance._**

Now that our instance is built we should be able to see the website in a browser.  I can simply grab the URL from the output here and open it to see if the website deployed correctly.  Note that it took about three minutes to deploy this simple website and shopping cart.  Wouldn't it be nice if I could go even faster?  We've got a tool for that too, and it's called Packer.  

## Act 1, Scene 2 - Go faster with Packer

Packer lets you automatically build machine images that have most or all of your software pre-installed right on the disk.  This can greatly reduce the amount of time it takes to provision new infrastructure, because you no longer have to install everything from scratch each time you launch an instance.

Let's go ahead and use the same exact Chef cookbook that we used to deploy this dev site and build a reusable image with Packer.  

**_On the command line, run this from the main projectk directory: `packer build packer/ecomsite.json`_**

This command reads the packer config file and builds out a brand new AMI, or Amazon Machine Image for me.  Note that you can do this just as easily on Microsoft Azure, Google Cloud, or VMWare.  I have a preconfigured image that I built earlier that we can use right away, so we don't have to wait for this packer build to complete.  We're also going to add two more instances so that we have a total of three web servers.  Terraform is going to automatically place each one of these instances into a separate physical data center.  Amazon calls these 'zones'.  By spreading our application across multiple zones you make it much more resilient to failure.  With Terraform you can easily build dev environments that mimic your production ones.

**_Edit the demo\_ecommerce.tf and variables.tf files.  Bump the count of servers up to 3, and uncomment the lines for using the pre-built AMI.  Comment out the lines that install and run Chef to make it even faster._**

Now I'm going to go ahead and run 'terraform plan' again.  Note how terraform detects anything that needs to be changed or rebuilt.  I can also blow away the entire environment and recreate it from scratch with the `terraform destroy` command.  Let's go ahead and apply our changes.

**_Run `terraform apply` and watch the output.  It should be done in ~30 seconds._**

Wow, what a difference.  Now we're starting to gain some more efficiency and speed.  Remember that this process used to take George several hours to complete with the on-premises infrastructure back in the office.  At this point we have three web servers.  Why don't we go ahead and add a load balancer and DNS name for the dev site, to make it easy for developers to access, and to keep the environment as similar to production as possible.

## Act 1, Scene 3 - Automate everything with Terraform Enterprise

**_Walk through the demo\_ecommerce.tf file again and uncomment all the lines in 'part 2'.  Save the file and run `terraform apply`_**

The new resources we are building include a load balancer, a target group, and target group attachments for each of our machines.  We also add a DNS record for dev.spacelyspacesprockets.info.  At Hashicorp, when we say infrastructure as code, we actually mean it.  All of your infrastructure can be defined and built using Terraform.

Everything you've seen so far can be built with our open source tools.  This works great for a single developer or sysadmin working in a small environment.  What if you have multiple users and globally distributed dev teams who need to collaborate together?  Many organizations are also subject to internal and external security and audit requirements.  When you're ready to move from a single-user workflow into a busy data center or cloud environment, you will want to have more controls around collaboration and governance.

This is where Terraform enterprise comes in.  Terraform Enterprise includes a graphical workflow interface, an approval process for plan changes and promotions, and strong RBAC controls for reducing risk and staying compliant.  We are happy to help you get set up with a Terraform Enterprise beta license so you can try it out yourself.

## Act 2 - Vault and Consul Demo

### Act 2, Scene 1 - Deploy and manage production SSL cert with Vault & Consul

**_Before you begin this part of the demo, you should have already spun up the production environment from the 'full\_demo' directory, using the `terraform apply` command.  You should also follow the steps in the main README.md file to initialize and unseal the Vault.  You can pre-configure the secret.rb recipe as well so it already has a valid token and URL set for your demo.  This part must be done on the node you are running chef on, not your local workstation.  The cookbooks are all in the /tmp/cookbooks directory._**

The systems engineering team met their deadline and were able to move the entire development environment onto AWS by the end of the month.  Now let's move on to the production environment, where the stakes are much higher.  The production environment contains passwords, ssl settings, tokens and other sensitive data that must be protected with the highest levels of encryption and access controls.  Getting these files and settings into the right place during an automated build process is very challenging.  The team wants to go fast, but they also have to remain secure.

We've deployed two more Hashicorp tools to help manage our production workloads, namely Consul and Vault.  Both of these tools have open source and enterprise versions.

Consul has multiple components, but as a whole, it is a tool for discovering and configuring services in your infrastructure.  Consul includes a simple and powerful service discovery tool, built-in health checking for your applications and infrastructure, a global key/value store, and multi-datacenter support.  

Vault secures, stores, and tightly controls access to tokens, passwords, certificates, API keys, and other secrets. Vault handles leasing, key revocation, key rolling, and auditing. Through a unified API, users can access an encrypted Key/Value store and network encryption-as-a-service, or generate AWS IAM/STS credentials, SQL/NoSQL databases, X.509 certificates, SSH credentials, and more.  Vault can integrate with Consul as its storage backend.

Let's start with a tour of the production environment.  It looks a lot like the dev environment but with some extra machines for managing our infrastructure.  We have three Consul servers, and three Vault servers.  Each of these is placed in a different physical data center for maximum reliability and HA.  Lets take a look at the UI of one of the Consul servers.

**_Open the Consul server master URL that you got from the outputs._**

This is the UI of one of my Consul servers.  All the data is replicated to all the other servers in the on-premises data center or AWS region.  Each of the three consul servers is running on separate physical infrastructure.  Here we get a quick visual representation of the health status of all our health checks.  This data is shared across all Consul agents via a secure gossip protocol, with update times measured in microseconds.  The nodes view shows me a bit more detail about each node in the cluster.  And here is the key value store, which we are using as the storage backend for Vault.

If we take a look in the logical/ storage area we can see some key names.  Earlier I loaded a username, a password, and an SSL certificate into Vault.  Note that when I click on these that all I can see is a bunch of garbled characters.  This is because the data is highly encrypted and can only be unencrypted by an authorized Vault client with a valid token.  There are several ways that a client can receive a token.  One of these ways is to provide the token during your provisioning process.  

Let's take a look at how we can use Vault to automate configuration of secure passwords and SSL certificates.  Our sysadmin George uses Chef to build and manage his fleet of servers.  Vault is easy to integrate with popular configuration tools like Chef or Puppet.  Normally Chef runs on a schedule, checking your machines every 30 minutes for configuration changes or updates.  I'm going to kick of a manual Chef run to illustrate how the encrypted files get from our Consul storage backend onto the machine in a safe and secure way.

**_Open the secret.rb file stored in the shared/cookbooks/demo-ecommmerce/recipes directory._**

This is a Chef recipe that illustrates two different ways you can use Vault.  The first is to render data into a template.  In this case we're going to insert a username and password into a text file.  You might have to do this to configure a database connector or other credentials file.  The second is going to put an SSL certificate into the correct directory for our application.  For this part we are using pure Ruby code.  Vault is flexible and extensible and supports the most popular programming languages and SDKs.

Let's run our Chef recipe now.

**_From the /tmp directory on your server, run `chef-client -z -o demo-ecommerce::secret`.  This will create the username/password template file and also drop your SSL certificate into /user/share/tomcat/webapps/WEB-INF/.  Use the `cat` and `ls -l` commands to show that these files were just created and have the correct contents._**

This demo is meant to give you a small preview of what's possible with Hashicorp Vault and Consul.  The Enterprise versions of these products enable extra features like multi-datacenter support, disaster recovery replication, MFA authentication and either silver or gold level support.  If you'd like to take Consul or Vault Enterprise for a spin we are happy to give you a demo and trial license so you can see how it meets your needs.

## Act 3 - Nomad Demo

### Act 3, Scene 1 - Manage application workloads using Nomad

COMING SOON TO A DEMO NEAR YOU