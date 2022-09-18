# Automate-AWS-Infrastructure-Project-using-Terraform




The Project Goal here is : 

    Using Terraform to provision AWS Infrastructure to :

      Prevision an aws-ec2 instance on aws infrastructure.
      Run nginx docker container on ec2-instance.



First 
we have to provision aws infrastructure to do that using Terraform 
We must add these resources to our .tf file 
Steps : 

Create custom vpc.
![](images/.1png)



Create a custom subnet.
![](images/.2png)

Carete cidr blocks ( VPC & Subnet). 
Create route table and internet gateway provision ec2 instance.  
Create a security group. 




Second : 
Provision ec2 instance : 
We must add these resources to our .tf file
Create a key pair for ssh into instance.







Final step :


Run initial commands to run an nginx container on ec2-server 


We create a entry-server.sh file and reference it into our ec2 instance resource by adding user_data attribute 





