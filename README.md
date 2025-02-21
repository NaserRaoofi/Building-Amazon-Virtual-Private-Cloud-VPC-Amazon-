# Building an Amazon Virtual Private Cloud (VPC)

## Overview
This project demonstrates how to build and configure an **Amazon Virtual Private Cloud (VPC)** from scratch using **AWS CloudFormation**. It includes the setup of **public and private subnets, an Internet Gateway, route tables, security groups, an EC2 web server, and an Amazon RDS database**.

![VPC Architecture](https://github.com/user-attachments/assets/ef256501-1a92-43dc-a2ae-5bded0ee15d6)

---

## Features
- **VPC Setup**: Creates a secure virtual network with **public and private subnets**.
- **Internet Connectivity**: Configures an **Internet Gateway** and appropriate **route tables**.
- **Security Groups**: Implements firewall rules for **web server and database** access.
- **Web Server (EC2)**: Deploys an EC2 instance in a **public subnet** with Apache and PHP.
- **Amazon RDS (MySQL)**: Sets up an RDS database in a **private subnet**, secured with security groups.
- **CloudFormation Automation**: Uses **AWS CloudFormation** for infrastructure as code (IaC).

---

## Architecture Diagram
This project follows the **AWS best practices** for VPC networking:

- **Public Subnet**: Hosts the **EC2 web server**.
- **Private Subnet**: Hosts the **RDS MySQL database**.
- **Internet Gateway**: Provides access to the public subnet.
- **Security Groups**: Restrict access between the web server and database.

---

## Prerequisites
Before deploying this infrastructure, ensure you have:
- An **AWS account**.
- The **AWS CLI** installed and configured.
- **CloudFormation permissions** to create VPC and EC2 instances.

---

## Deployment Instructions

### **1. Clone the Repository**
```sh
 git clone https://github.com/your-username/Building-Amazon-VPC.git
 cd Building-Amazon-VPC
```

### **2. Deploy the CloudFormation Stack**
```sh
 aws cloudformation create-stack --stack-name MyVPCStack --template-body file://vpc-template.yaml --capabilities CAPABILITY_IAM
```

### **3. Retrieve Outputs**
```sh
 aws cloudformation describe-stacks --stack-name MyVPCStack --query "Stacks[0].Outputs"
```

### **4. Connect to EC2 Instance**
```sh
 ssh -i your-key.pem ec2-user@<EC2-Public-IP>
```

### **5. Test Database Connection**
```sh
 mysql -h <RDS-Endpoint> -u admin -p
```

---

## Project Structure
```
/ Building-Amazon-Virtual-Private-Cloud-VPC-Amazon
├── parameters/
│   ├── ec2-params.json
│   ├── rds-params.json
│   ├── vpc-params.json
├── scripts/
│   ├── deploy.sh          # Script to deploy CloudFormation stack
│   ├── cleanup.sh         # Script to delete CloudFormation stack
├── templates/
│   ├── ec2.yaml           # EC2 configuration
│   ├── outputs.yaml       # CloudFormation outputs
│   ├── rds.yaml           # RDS configuration
│   ├── security-groups.yaml # Security groups setup
│   ├── vpc.yaml           # VPC setup
│   ├── main-stack.yaml    # Main CloudFormation stack
├── .gitignore             # Ignore sensitive and unnecessary files
├── README.md              # Project documentation            # Project documentation
```

---

## Future Enhancements
- Implement **Auto Scaling and Load Balancing**.
- Add **CloudWatch monitoring** and **logging**.
- Configure **AWS Secrets Manager** for database credentials.

---

## License
This project is licensed under the **MIT License**.

---

## Author
**Your Name**  
[GitHub](https://github.com/NaserRaoofi) | [LinkedIn](https://www.linkedin.com/in/naser-raoofi/)


---

## Contributions
Contributions are welcome! Feel free to submit a **pull request** or open an **issue**.
