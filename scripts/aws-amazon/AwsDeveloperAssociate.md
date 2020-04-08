# AWS CERTIFIED DEVELOPER ASSOCIATE
#### Certification Roadmap

<table>
    <tr>
        <th>AWS Certified</th>
        <th colspan="4">Role - Based Certifications</th>
        <th>Specialty Certifications</th>
    </tr>
    <tr>
        <td>Profesional</td>
        <td></td>
        <td>
          AWS Certified<br>
          <b>Solutions Architect</b><br>
          <i>- Profesional</i>
        </td>
        <td>
          AWS Certified<br>
          <b>DevOps Engineer</b><br>
          <i>- Profesional</i>
        </td>
        <td>
          AWS Certified<br>
          <b>DevOps Engineer</b><br>
          <i>- Profesional</i>
        </td>
        <td>
          AWS Certified<br>
          <b>Advanced Networking</b><br>
          <i>- Specialty</i>
        </td>
    </tr>
    <tr>
        <td>Associate</td>
        <td></td>
        <td>
          AWS Certified<br>
          <b>Solutions Architect</b><br>
          <i>- Associate</i>
        </td>
        <td>
          AWS Certified<br>
          <b>Developer</b><br>
          <i>- Associate</i>
        </td>
        <td>
          AWS Certified<br>
          <b>SysOps Administrator</b><br>
          <i>- Associate</i>
        </td>
        <td>
          AWS Certified<br>
          <b>Big Data</b><br>
          <i>- Specialty</i>
        </td>
    </tr>
    <tr>
        <td>Foundational</td>
        <td>
          AWS Certified<br>
          <b>Cloud Practitioner</b><br>
        </td>
        <td>
          AWS Certified<br>
          <b>Cloud Practitioner</b><br>
          <i>- Optional</i>
        </td>
        <td>
          AWS Certified<br>
          <b>Cloud Practitioner</b><br>
          <i>- Optional</i>
        </td>
        <td>
          AWS Certified<br>
          <b>Cloud Practitioner</b><br>
          <i>- Optional</i>
        </td>
        <td>
          AWS Certified<br>
          <b>Security</b><br>
          <i>- Specialty</i>
        </td>
    </tr>
    <tr>
        <td></td>
        <td>Cloud Practitioner</td>
        <td>Architect</td>
        <td>Developer</td>
        <td>Operations</td>
    </tr>
</table>

#### AWS topics structure
- Amazon EC2
- Amazon ECR
- Amazon ECS
- Amazon Elastic Beanstalk
- AWS Lambda
- Elastic Load Balancing
- Amazon CloudFront
- Amazon Kinesis
- Amazon Route S3
- Amazon S3
- Amazon RDS
- Amazon DynamoDB
- Amazon DynamoDB Accelerator
- Amazon ElastiCache
- Amazon SQS
- Amazon SNS
- AWS Step Functions
- Amazon SWF
- Amazon API Gateway
- Amazon SES
- Amazon Cognito
- IAM
- Amazon CloudWatch
- Amazon EC2 System Manager
- AWS CloudFormation
- AWS CloudTrail
- AWS CodeCommit
- AWS CodeBuild
- AWS CodeDeploy
- AWS CodePipeline
- AWS X-Ray
- AWS KMS


#### AWS Management Console
- Go to our account
- Click on Billing Dashboard
- In left side are a menu: Cost Management -> Budgets Click on it.
- Create a budget
- Cost Budget
- Set budget
- Fill the required fields.
- Spend money would be configured form 0.01 $us
- Click on configure alerts.
- Fill required fields.
- Confirm budget.
- Create.

#### IAM Introduction
- IAM (Identity and Access Management)
- Your whole AWS security is there:
  - Users
  - Groups
  - Roles
- Root account should never be used (and shared)
- Users must be created with proper permissions 
- IAM is at the center of AWS 
- Policies are written in JSON (JavaScript Object Notation): Defines what each of the above can and cannot do.



- IAM has a globalview: It will be across all the regions
- Permissions are governed by Policies (JSON) 
- MFA (Multi Factor Authentication) can be setup 
- IAM has predefined “managed policies” 
- We’ll see IAM policies in details in the future 
- It’s best to give users the minimal amount of permissions they need to perform their job (least privilege principles)


For big enterprises it is used something called:
##### IAM Federation 
- Big enterprises usually integrate their own repository of users with IAM 
- This way, one can login into AWS using their company credentials 
- Identity Federation uses the SAML standard (Active Directory)

##### Summary

- One IAM User per PHYSICAL PERSON: Do not share with anyone, your account is your account!
- One IAM Role per Application 
- IAM credentials should NEVER BE SHARED 
- Never, ever, ever, ever, write IAM credentials in code. EVER. 
- And even less, NEVER EVER EVER COMMIT YOUR IAM credentials 
- Never use the ROOT account except for initial setup. 
- Never use ROOT IAM Credentials

##### IAM Hands-On
1. Go to AWS Console
2. Select IAM in the services dashboard: Remember that this operations are global, it is not specific for a region.
3. Delete your root access keys: Is the first operation that we will need to do (This is going to be performed).
4. Activate MFA rule.
   - Enable to credentials
   - Multi-factor authentication (MAF) sub menu -> Activate MFA
   - (Virtual or Hardware) If it is virtual, we can use an application. Such us google authenticator.
   - We will need to scan a QR code, then fill the fields based on the result of the scan.
   - After filled the fields, press Activate
   - Finish
5. Create individual IAM Users.
   - Manage users
   - Add user -> Fill the user name field -> Select AWS access type
     - In this case selecting both (Programmatic access and AWS Management Console access)
   - Console password
     - The options are: Autogenerated password or Custom Password.
   - Require password reset
     - Checked in this case.
   - Next (Set Permission)
   - In this case selecting ```Attach existing policies directly```
     - Giving in this case ```Administrator Access```
   - Set Permissions boundary
     - Create user without a permissions boundary (in this case)
   - Next (Review)
   - Create User
   - Close.
6. Manage groups
   - Create a new group
     - For this scenario named it ```admin```
   - Next step
     - Administrator Access
   - Next step
   - Create group
   - Go to the created group
   - User Tab -> Add Users to Group -> Add the user created in previous steps.
   - Go to the user, verify that it has the group, and detach the ```Attached directly``` roles.
7. Apply an IAM password policy
   - Manage password policy
   - Set password policy -> Configure all requerid policies
   - Save changes.

After performed all the steps above, you should see all green status for IAM Management dashboard.

8. In IAM dashboard we can assign an alias to the conection. Press customize link and add a name. So the link is going to change based on the name added. It is going to be used for signIn into our AWS console.

```https://fraldemoacc.signin.aws.amazon.com/console```

#### What is EC2?
- EC2 is one of most popular of AWS offering 
- It mainly consists in the capability of : 
  - Launching virtual machines in the cloud.
  - Renting virtual machines (EC2) 
  - Storing data on virtual drives (EBS) 
  - Distributing load across machines (ELB) 
  - Scaling the services using an auto-scaling group (ASG)
- Knowing EC2 is fundamental to understand how the Cloud works

##### Hands-On: Launching an EC2 Instance running Linux
- We’ll be launching our first virtual server using the AWS Console 
- We’ll get a first high level approach to the various parameters 
- We’ll learn how to start / stop / terminate our instance.

1. Go to AWS console
2. Go to EC2 Service
   - Before continue, make sure that you are in the region that is close to you.
3. Launch Instance: Choose an Amazon Machine Image (AMI)
   - For our case we are going to choose ```Amazon Linux 2 AMI```
4. Select the AMI: Choose an instance type
   - Select t2.micro
   - Then press NEXT: Configure instance details
5. Step 3: Configure Instance Details
   - For this first scenario, leave all fields with their default values.
   - Click NEXT: Add Storage
6. Step 4: Add Storage
   - For this first scenario, leave all fields with their default values.
   - Click NEXT: Add Tags
7. Step 5: Add Tags. 
   - Tags are basically key value pairs which allow you to just identify that Instance and classify it.
   - Example: Name -> FirstInstance
   - It can be added as many tags as required.
   - Click NEXT: Configure Security Group
8. Step 6: Configure Security Group
   - This is going to be basically a firewall for the instance.
   - The following fields are filled.
     - Security group name: ```ec2a-security-group```
     - Description: ```Create with my first EC2 Instance```
   - Click on Review and Lunch
9. Step 7: Review Instance Lunch
   - There is a WARNING message that says: ```Your security group is open to the world```. This needs to be fixed, but for now it is ok.
   - Click on LAUNCH
10. Select an existing key pair or create a new key pair.
    - For now choose create a new key pair
    - Add a key pair name and download it.
    - Then press in LAUNCH INSTANCES
    - Then View Instances

##### How to SSH into your EC2 Instance
###### Linux / Mac OSX

1. We’ll learn how to SSH into your EC2 instance using Linux / Mac 
2. SSH is one of the most important function. It allows you to control a remote machine, all using the command line.

> On the TAB Description we can see some important information regarding to public IPs and DNS. And this is basically how we can connect over the web to our EC2 Instance.
We can also see in `Security Groups` section a `view inbound rules` which shows us the enable ports for this instance.

> We need to follow these steps:
   
   - Open the terminal
   - Execute the following command. `ssh ec2-user@<public-ec2-ip>` where _ec2-user_ is basically the Linux user into our Amazon Linux machine, and _@_ basically defines the IP.
   - But you may get a `Permission Denied` error message. That is because we need to use the key (.pem file)
   - `ssh -i <pem-file> ec2-user@<public-ec2-ip>`
   - At this time I get another error message (exam question): `WARNING: UNPROTECTED PRIVATE KEY FILE!` _Permissions 0644 for 'pem file' are too open_ So basically because the private key is accesible by others it will say bad permissions, and it will not allow you to SSH into that machine.
   - So to fix the previous error: `chmod 0400 <pem-file>`
   - `ssh -i <pem-file> ec2-user@<public-ec2-ip>`
   - So the connection should be success!
   - `whoami` command should show _ec2-user_

3. We will see how we can configure OpenSSH ```~/.ssh/configto``` facilitate the SSH into our EC2 instance

###### Windows

1. We’ll learn how to SSH into your EC2 instance using Windows 
2. SSH is one of the most important function. It allows you to control a remote machine, all using the command line.
3. We will configure all the required parameters necessary for doing SSH on Windows using the free tool Putty.

###### Steps
- Install Putty
- Run putty and go to PuTTygen. Using this tool we are going to convert the key we have downloaded from the EC2 console and we are going to convert it into a format that puTTY likes, which is called PPK.
  - Click on File menu
  - Load private key
  - Select the private key. `It will show a message: Successfully imported foreign key.....`
  - Click on `Save private key`, then choose a location where to save the new ppk file.
  - Click on `Save` and close the generator
- Go to the `programs` menu and choose putty.
  - Enter the IP address of our ec2 machine in the following format: `ec2-user@<ec2-instance-ip>`
  - We can save the session giving it a name, and clicking on `save` button.
  - Click twice in the instance and you may get an error message like: `No supported authentication methods available .....`. It is because we haven't linked our private key file. Close the window.
  - Go to putty again, and load the instance.
  - Go to `connection -> SSH -> Auth -> <Here we can find a field 'private key file for authentication'>`
  - Browser and load the ppk file, but dot not close the window yet!
  - Go to `Session` then save it again selecting the right session name.
  - Double click, and we are inside the machine.
  - exit for closing the connection.

#### Security Groups?
##### Introduction

1. Security Groups are the fundamental of network security in AWS 
2. They control how traffic is allowed into or out of our EC2 Machines.
3. It is the most fundamental skill to learn to troubleshoot networking issues 
4. In this lecture, we’ll learn how to use them to `allow`, `inbound` and `outboundport`

###### Hands-On
- When you are located in a instance, you can click on `Description tab -> security group -> link before inbound rules`
- Or you can navigate in the left menu to `Network & Security -> Security Groups`
- In the security groups we have some tabs `DESCRIPTION | INBOUND | OUTBOUND | TAGS`
  - Under `inbound`: This is all the rules that will allow traffic into our EC2 machine. And by default, there is no rules and we have to add rules.
  - Under `outbound`: By default all traffic is enabled out of the machine. And that means that the machine can communicate everything, everywhere (that is fine by the way).
  - Under `Tags` is if you want to add a name tag, or whatever you want for your EC2 for your security group
- What happens when we delete the default `inbound` rule? So when you try to connect again, while the port 22 is not allowed it will just wait, and wait and wait TIME OUT. That is because we are not allowing nothing in port 22.

##### Deeper Dive

1. Security groups are acting as a “firewall” on EC2 instances 
2. They regulate: 
   - Access to Ports 
   - Authorised IP ranges –IPv4 and IPv6 
   - Control of inbound network (from other to the instance) 
   - Control of outbound network (from the instance to other)

###### Example
<table>
    <tr>
        <th>Type</th>
        <th>Protocol</th>
        <th>Port Range</th>
        <th>Source</th>
        <th>Description</th>
    </tr>
    <tr>
        <td>HTTP</td>
        <td>TCP</td>
        <td>80</td>
        <td>0.0.0.0/0</td>
        <td>Test http page</td>
    </tr>
    <tr>
        <td>SSH</td>
        <td>TCP</td>
        <td>22</td>
        <td>192.149.196.85/32</td>
        <td></td>
    </tr>
    <tr>
        <td>Custom TCP Rule</td>
        <td>TCP</td>
        <td>4567</td>
        <td>0.0.0.0/0</td>
        <td>My App</td>
    </tr>
</table>

###### Good to know

1. Can be attached to multiple instances 
2. Locked down to a region / VPC combination 
3. Does live “outside” the EC2 –if traffic is blocked the EC2 instance won’t see it 
4. _It’s good to maintain one separate security group for SSH access_
5. If your application is not accessible (time out), then it’s a security group issue 
6. If your application gives a “connection refused“ error, then it’s an application error or it’s not launched 
7. All inbound traffic is `blocked` by default 
8. All outbound traffic is `authorised` by default


#### Private vs Public IP (IPv4)

1. Networking has two sorts of IPs. IPv4 and IPv6: 
   - IPv4: 1.160.10.240 
   - IPv6: 3ffe: 1900:4545:3:200:f8ff:fe21:67cf 
2. In my example, I will only be using IPv4. 
3. IPv4 is still the most common format used online. 
4. IPv6 is newer and solves problems for the Internet of Things (IoT).
5. IPv4 allows for 3.7 billion different addresses in the public space 
6. IPv4: [0-255].[0-255].[0-255].[0-255].

##### Fundamental Differences

1. Public IP: 
   - Public IP means the machine can be identified on the internet (WWW) 
   - Must be unique across the whole web (not two machines can have the same public IP). 
   - Can be geo-located easily

2. Private IP: 
   - Private IP means the machine can only be identified on a private network only 
   - The IP must be unique across the private network 
   - BUT two different private networks (two companies) can have the same IPs. 
   - Machines connect to WWW using an internet gateway (a proxy) 
   - Only a specified range of IPs can be used as private I

3. Elastic IPs

1. When you stop and then start an EC2 instance, it can change its public IP. 
2. If you need to have a fixed public IP for your instance, you need an Elastic IP 
3. An Elastic IP is a public IPv4 IP you own as long as you don’t delete it 
4. You can attach it to one instance at a time
5. With an ElasticIPaddress, you can mask the failure of an instance or software by rapidly remapping the address to another instance in your account. 
6. You can only have 5 Elastic IP in your account (you can ask AWS to increase that).
7. Overall, `try to avoid using Elastic IP`: 
   - They often reflect poor architectural decisions 
   - Instead, use a random public IP and register a DNS name to it 
   - Or, as we’ll see later, use a Load Balancer and don’t use a public IP

##### Hands-On

1. By default, your EC2 machine comes with: 
   - A private IP for the internal AWS Network 
   - A public IP, for the WWW. 
2. When we are doing SSH into our EC2 machines: 
   - We can’t use a private IP, because we are not in the same network 
   - We can only use the public IP. 
3. If your machine is stopped and then started, `the public IP can change`

###### Steps
- Connect SSH with the instance.
- So if we use the private IP, nothing happens, because we are not in the same network.
- But if we stop our instance, the IP is lost, and when we start again, the public IP changes.

- We can see also Elastic IPs in the left menu.
  - `Network and Security -> Elastic IPs`
  - Click on `Allocate new address` then `Allocate`. So we get an elastic IP.
- Once allocated a elastic IP, what we can do is right click and associate that address with our instance
  - Right click -> Associate Address -> Fill all the fields -> click on Associate
  - If we go back to our instance, we can find that the IPv4 public IP now is the ALLOCATED ONE.
  - Now if we stop the instance and restart it, the same IP will be associated.
- For removing the Elastic IP
  - Right click on the instance -> Networking -> Disassociate Elastic IP Address -> Yes, disassociate
  - Go to elastic IPs -> Right click -> Release Elastic IP -> Release
  - It is not good idea to have enable it, because if we do not use it we are going to be billed for it.
- Once release the Elastic IP.
  - Next time a new public IP will be assigned to our instance.

#### Launching an Apache Server on EC2
1. Let’s leverage our EC2 instance
2. We’ll install an Apache Web Server to display a web page 
3. We’ll create an index.html that shows the hostname of our machine

###### Steps
- First connect throught SSH to our EC2 instance
- Run the following commands
  ```batch
  sudo su
  
  #It is important to keep all the packages updated.
  yum update -y 
  
  # Install httpd
  yum install -y httpd.x86_64
  
  # Start the service
  ## Common error: If you get bash: systemctl command not found. Make sure you are using Amazon Linux 2, not Amazon Linux.
  systemctl start httpd.service
  
  # To ensure that the system remains enabled across reboots, we say enable httpd.service
  systemctl enable httpd.service
  
  # Let vefity if the service is ON, it should display a html response.
  curl localhost:80
  ```
- We can also open throught a browser with the public IP. But we may get an timeout issue, why does it happen? It may be due to the SECURITY GROUPS
- So until now we have enabled only port 22 for SSH connections.
- For fixing this issue we need to apply a new Security Group.
  - Go to `Network & Security -> Security Groups -> Inbound`
  - Add a new rule: `HTTP - TCP - 80 - 0.0.0.0/0 - Allow HTTP traffic for Apache`
  - Go back to the browser and we can see a response page from the httpd service.
- So now we can basically add some content to `var/www/html/`
  - `"Hello world from $(hostname -f)" > /var/www/html/index.html`
  - Once performed the previous operation, you will see those changes in your browser.
  
#### EC2 User Data

1. It is possible to bootstrap our instances using an `EC2 User data` script. 
2. `bootstrapping` means launching commands when a machine starts 
3. That script is `only run once` at the instance `first start` 
4. EC2 user data is used to automate boot tasks such as: 
   - Installing updates 
   - Installing software 
   - Downloading common files from the internet 
   - Anything you can think of 
5. The EC2 User Data Script runs with the root user

##### Hands-On

1. We want to make sure that this EC2 instance has an Apache HTTP server installed on it–to display a simple web page 
2. For it, we are going to write a user-data script. 
3. This script will be executed at the first boot of the instance. 
4. Let’s get hands on!

###### Steps

1. Terminate the instances or instance that we created as a example.
2. We will create another one choosing `Amazon Linux 2 AMI` again.
   - `t2.micro` instance
   - Configure the instance details
   - Advance Details: Here we have a USER DATA field.
   - In the user data field we first will need `#!/bin/bash` in the top, otherwise it will not work. `Remember, EC2 User Data is automatically run with the sudo command`
   ```bash
   #!/bin/bash
   
   # install httpd (Linux 2 version)
   yum update -y
   yum install -y httpd.x86_64
   systemctl start httpd.service
   systemctl enable httpd.service
   echo "Hello World from $(hostname -f)" > /var/www/html/index.html
   ```
   - Click on next
   - For security group, we will use an existing one. And this is perfect because it allows SSH and the port 80, which we configured from before.
   - Click on Review and Launch.
   - Click on Launch. So we can use the existing keypair.
   - Click on Laucn Instances (It is completed.)
3. If everything went well, copying the public IP generated for the instance to a brower, we can see the changes there.
4. We should also able to SSH into that new EC2 Instance machine.

#### EC2 Instance Launch Types

1. On Demand Instances: short workload, predictable pricing 
2. Reserved Instances: long workloads (>= 1 year) 
3. Convertible Reserved Instances: long workloads with flexible instances 
4. Scheduled Reserved Instances: launch within time window you reserve 
5. Spot Instances: short workloads, for cheap, can lose instances 
6. Dedicated Instances: no other customers will share your hardware 
7. Dedicated Hosts: book an entire physical server, control instance placement

##### EC2 On Demand

- Pay for what you use (billing per second, after the first minute) 
- Has the highest cost but no upfront payment • No long term commitment
- Recommended for short-term and un-interrupted workloads, where you can't predict how the application will behave.

##### EC2 Reserved Instances

- Up to 75% discount compared to On-demand 
- Pay upfront for what you use with long term commitment 
- Reservation period can be 1 or 3 years 
- Reserve a specific instance type 
- Recommended for steady state usage applications (think database)

##### Convertible Reserved Instance 

- can change the EC2 instance type 
- Up to 54% discount 

##### Scheduled Reserved Instances 

- launch within time window you reserve 
- When you require a fraction of day / week / month
  
##### Spot Instances

- Can get a discount of up to 90% compared to On-demand 
- You bid a price and get the instance as long as its under the price 
- Price varies based on offer and demand 
- Spot instances are reclaimed with a 2 minute notification warning when the spot price goes above your bid

- Used for batch jobs, Big Data analysis, or workloads that are resilient to failures. 
- Not great for critical jobs or databases

##### Dedicated Instances

- Instances running on hardware that’s dedicated to you 
- May share hardware with other instances in same account 
- No control over instance placement (can move hardware after Stop / Start)

<table>
    <tr>
        <th>Characteristic</th>
        <th>Dedicated Instances</th>
        <th>Dedicated Hosts</th>
    </tr>
    <tr>
        <td>Enables the use of dedicated physical servers</td>
        <td>X</td>
        <td>X</td>
    </tr>
    <tr>
        <td>Per instance billing (subject to a $2 per region free)</td>
        <td>X</td>
        <td></td>
    </tr>
    <tr>
        <td>Per host billing</td>
        <td></td>
        <td>X</td>
    </tr>
    <tr>
        <td>Visibility of sockets, cores, host ID</td>
        <td></td>
        <td>X</td>
    </tr>
    <tr>
        <td>Affinity between a host and instance</td>
        <td></td>
        <td>X</td>
    </tr>
    <tr>
        <td>Targeted instance placement</td>
        <td></td>
        <td>X</td>
    </tr>
    <tr>
        <td>Automatic instance placement</td>
        <td>X</td>
        <td>X</td>
    </tr>
    <tr>
        <td>Add capacity using an allocation request</td>
        <td></td>
        <td>X</td>
    </tr>
</table>

##### Dedicated Hosts

- Physical dedicated EC2 server for your use 
- Full control of EC2 Instance placement 
- Visibility into the underlying sockets / physical cores of the hardware 
- Allocated for your account for a 3 year period reservation 
- More expensive
- Useful for software that have complicated licensing model (BYOL – Bring Your Own License) 
- Or for companies that have strong regulatory or compliance needs

###### Which host is right for me?

- **On demand**: coming and staying in resort whenever we like, we pay the full price 
- **Reserved**: like planning ahead and if we plan to stay for a long time, we may get a good discount. 
- **Spot instances**: the hotel allows people to bid for the empty rooms and the highest bidder keeps the rooms. You can get kicked out at any time 
- **Dedicated Hosts**: We book an entire building of the resort

#### EC2 Pricing

- EC2 instances prices (per hour) varies based on these parameters: 
  - Region you’re in 
  - Instance Type you’re using 
  - On-Demand vs Spot vs Reserved vs Dedicated Host 
  - Linux vs Windows vs Private OS (RHEL, SLES, Windows SQL) 
- You are billed by the second, with a minimum of 60 seconds. 

- You also pay for other factors such as storage, data transfer, fixed IP public addresses, load balancing 
- *You do not pay for the instance if the instance is stopped*

###### Example

- t2.small in US-EAST-1 (VIRGINIA), cost $0.023 per Hour 
- If used for: 
  - 6 seconds, it costs $0.023/60 =  $0.000383 (minimum of 60 seconds) 
  - 60 seconds, it costs $0.023/60 =  $0.000383 (minimum of 60 seconds) 
  - 30 minutes, it costs $0.023/2 =  $0.0115 
  - 1 month, it costs $0.023 * 24 * 30 = $16.56 (assuming a month is 30 days) 
  - X seconds (X > 60), it costs $0.023 * X / 3600 
  
- The best way to know the pricing is to consult the pricing page: https://aws.amazon.com/ec2/pricing/on-demand/

##### What is an AMI?

- As we saw, AWS comes with base images such as: 
  - Ubuntu 
  - Fedora 
  - RedHat 
  - Windows 
  - Etc… 
- These images can be customised at runtime using EC2 User data
- But what if we could create our own image, ready to go? 
- That’s an AMI –an image to use to create our instances 
- AMIs can be built for Linux or Windows machines

##### Why would you use a custom AMI?

- Using a custom built AMI can provide the following advantages: 
  - Pre-installed packages needed 
  - Faster boot time (no need for long ec2 user data at boot time) 
  - Machine comes configured with monitoring / enterprise software 
  - Security concerns –control over the machines in the network 
  - Control of maintenance and updates of AMIs over time 
  - Active Directory Integration out of the box 
  - Installing your app ahead of time (for faster deploys when auto-scaling) 
  - Using someone else’s AMI that is optimised for running an app, DB, etc… 
  
- **AMI are built for a specific AWS region (!)**

##### EC2 Instances Overview

- Instances have 5 distinct characteristics advertised on the website: 
  - The RAM (type, amount, generation) 
  - The CPU (type, make, frequency, generation, number of cores) 
  - The I/O (disk performance, EBS optimisations) 
  - The Network (network bandwidth, network latency) 
  - The Graphical Processing Unit (GPU) 
  
- It may be daunting to choose the right instance type (there are over 50 of them) https://aws.amazon.com/ec2/instance-types/ 
- https://ec2instances.info/can help with summarizing the types of instances 
- R/C/P/G/H/X/I/F/Z/CR are specialised in RAM, CPU, I/O, Network, GPU 
- M instance types are balanced 
- T2/T3 instance types are “burstable

##### Burstable Instances (T2)

**What does that even mean?** Burstable instances is a concept that oeverall, the instance is okay CPU performance.

- AWS has the concept of burstable instances (T2 machines)
- Burst means that overall, the instance has OK CPU performance. 
- When the machine needs to process something unexpected (a spike in load for example), it can burst, and CPU can be VERY good. 
- If the machine bursts, it utilizes “burst credits” 
- If all the credits are gone, the CPU becomes BAD 
- If the machine stops bursting, credits are accumulated over time

- Burstable instances can be amazing to handle unexpected traffic and getting the insurance that it will be handled correctly 
- If your instance consistently runs low on credit, you need to move to a different kind of non-burstable instance (all the ones described before)

##### T2 Unlimited

- Nov 2017: It is possible to have an “unlimited burst credit balance” 
- You pay extra money if you go over your credit balance, but you don’t lose in performance

- Overall, it is a new offering, so be careful, costs could go high if you’re not monitoring the health of your instances
- Read more here: https://aws.amazon.com/blogs/aws/new-t2-unlimitedgoing-beyond-the-burst-with-high-performance/

##### EC2 –Checklist 

- Know how to SSH into EC2 (and change .pemfile permissions) 
- Know how to properly use security groups 
- Know the fundamental differences between private vs public vs elastic IP 
- Know how to use User Data to customize your instance at boot time 
- Know that you can build custom AMI to enhance your OS
- EC2 instances are billed by the second and can be easily created and thrown away, welcome to the cloud!


#### What is load balancing?

Basically a load balancer is a server that will front your application and it will forward all the internet traffic to your instances of your applications downstream.
- Load balancers are servers that forward internet traffic to multiple servers (EC2 Instances) downstream.

##### Why use a load balancer?

- Spread load across multiple downstream instances
- Expose a single point of access (DNS) to your application
- Seamlessly handle failures of downstream instances
- Do regular health checks to your instances
- Provide SSL termination (HTTPS) for your websites
- Enforce stickiness with cookies
- High availability across zones
- Separate public traffic from private traffic

##### Why use and EC2 Load Balancer?

- An ELB (EC2 Load Balancer) is a managed load balancer
  - AWS guarantees that it will be working
  - AWS takes care of upgrades, maintenance, high availability
  - AWS provides only a few configuration knobs
- It costs less to setup your own load balancer but it will be a lot more effort on your end.
- It is integrated with many AWS offerings / services

##### Types of load balancer on AWS

- AWS has 3 kinds of Load Balancers

- Classic Load Balancer (v1 - old generation) - 2009
- Application Load Balancer (v2 - new generation) - 2016
- Network Load Balancer (v2 - new generation) - 2017
- Overall, it is recommended to use the newer / v2 generation load balancers as they provide more features

- You can setup internal (private) or external (public) ELBs

##### Health Checks

- Health Checks are crucial for Load Balancers
- They enable the load balancer to know if instances it forwards traffic to are available to reply to requests
- The health check is done on a port and a route (/health is common)
- If the response is not 200 (OK), then the instance is unhealthy

##### Application Load Balancer (v2)

- Application load balancers (Layer 7) allow to do:
  - Load balancing to multiple HTTP applications across machines (target groups)
  - Load balancing to multiple applications on the same machine (ex: containers)
  - Load balancing based on route in URL
  - Load balancing based on hostname in URL

- Basically, they’re awesome for micro services & container-based application (example: Docker & Amazon ECS)
- Has a port mapping feature to redirect to a dynamic port

- In comparison, we would need to create one Classic Load Balancer per application before. That was very expensive and inefficient!

###### Good to know
- Stickiness can be enabled at the target group level
  - Same request goes to the same instance
  - Stickiness is directly generated by the ALB (not the application)
- ALB support HTTP/HTTPS & Websockets protocols
- The application servers don’t see the IP of the client directly
  - The true IP of the client is inserted in the header X-Forwarded-For
  - We can also get Port (X-Forwarded-Port) and proto (X-Forwarded-Proto)

##### Network Load Balancer (v2)

- Network load balancers (Layer 4) allow to do:
  - Forward TCP traffic to your instances
  - Handle millions of request per seconds
  - Support for static IP or elastic IP
  - Less latency ~100 ms (vs 400 ms for ALB)
  
- Network Load Balancers are mostly used for extreme performance and should not be the default load balancer you choose
- Overall, the creation process is the same as Application Load Balancers

###### Gook to know

- Classic Load Balancers are Deprecated
  - Application Load Balancers for HTTP / HTTPs & Websocket
  - Network Load Balancer for TCP
- CLB, ALB, NLB support SSL certificates and provide SSL termination
- All Load Balancers have health check capability
- ALB can route on based on hostname / path
- ALB is a great fit with ECS (Docker)
- Any Load Balancer (CLB, ALB, NLB) has a static host name. Do not resolve and use underlying IP
- LBs can scale but not instantaneously – contact AWS for a “warm-up”
-  NLB directly see the client IP
- 4xx errors are client induced errors
- 5xx errors are application induced errors
  - Load Balancer Errors 503 means at capacity or no registered target
- If the LB can’t connect to your application, check your security groups!

###### Load Balancers Hands On

1. Go to `Services -> left menu -> Load Balancing -> Load Balancers`
2. Create Load Balancer
   - As we can see, we have the classic load balancer, but that is "Previous Generation" and that is deprecated. And then we have "Application Load Balancer" and we have "Network Load Balancer" for high performance.
   - Since we do not need to take into account Network Load Balancer for this time, we will choose the other one.
3. Create "Application Load Balancer"
   - We need to fill all the fields.
   - We will choose `internet-facing` because we want it to be public. But if we want it to be private we need to choose `internal`
   - Choose the right IP version
   - Define the protocols
   - Choose the required availability zones.
   - Then next: `Configure Security Settings`.
4. Step 2 click next.
   - We will need to create a new security group. Give it a name: `web-ap-load-balancer-first`
   - Leave the fields as default for now.
   - Nex: `Configure Routing`
5. Configure Routing
   - This time we will need to create a new `target group` giving a name.
   - Protocol `HTTP`
   - Port `80`
   - Target type leave it as `instance`
   - Heal check options as default.
   - Next: `Register Targets
6. Register Targets
   - Click on the running instance
   - Click on `Add to registered`
   - Next: `Review`
7. Review
8. Create
9. In Load Balancers Dashboard it may take a while in `provisioning` state
   - It will change to `ACTIVE` state
   - To verify if that works, copy the DNS in the browser, it should display the web page configured in previous steps.
   - After configuring it, we can access to our EC2 instance through the load balancer or the IP. So there is are some steps only through the LoadBalancer.
   - That security groups can reference security groups.
   - If we take a look, in our panel, we have the different EC2 instances security groups, as well as our LoadBalancer ones. 
   - For adding the security group:
     - Choose the EC2 instance security group
     - Go to Inbound tab -> Edit
     - Make that the call only comes from the load balancer (typing sg).
     - Then save the changes.
     - After applied the changes, we will not able to access the page via IP anymore.
     - So that is a very secure setup, because now we guarantee that only the load balancer can talk to our HTTP instances on port 80. It also demostrate how to use basically a Security Group in another Security Group rule.




















