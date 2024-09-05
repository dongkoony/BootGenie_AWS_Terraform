# EC2 Autoscaling Module

[![EN](https://img.shields.io/badge/lang-en-blue.svg)](README-us.md) 
[![KR](https://img.shields.io/badge/lang-kr-red.svg)](README.md)

#### [한국어 문서 보기(KR)](README.md)


This directory contains Terraform configurations for AWS EC2 instance autoscaling. The module sets up Auto Scaling Groups (ASGs) for both web servers and application servers.

## Directory Structure

```
modules/ec2/
├── main.tf
├── outputs.tf
├── README.md
├── variables.tf
```

## Key Features

1. Creation of launch templates for web and app servers
2. Configuration of Auto Scaling Groups
3. Implementation of scale-in/out policies using CloudWatch alarms

## Scale In/Out Policies

### Web Servers
- **Scale Out**: When CPU utilization is above 70%
- **Scale In**: When CPU utilization is below 30%

### App Servers
- **Scale Out**: When CPU utilization is above 75%
- **Scale In**: When CPU utilization is below 30%

Both server types have a cooldown period of 300 seconds (5 minutes) between scaling actions.

## Code Structure Explanation

1. **Launch Template (`aws_launch_template`)**
   - Defines instance settings such as instance type, AMI, security groups, etc.
   - Performs initial instance setup through user data scripts.

2. **Auto Scaling Group (`aws_autoscaling_group`)**
   - Sets minimum, maximum, and desired capacity.
   - References the launch template to create new instances.

3. **CloudWatch Alarm (`aws_cloudwatch_metric_alarm`)**
   - Monitors CPU utilization to define scale-in/out conditions.

4. **Auto Scaling Policy (`aws_autoscaling_policy`)**
   - Triggered by CloudWatch alarms to adjust the number of instances.

## Usage

1. Set the necessary variables in the `variables.tf` file.
2. Call this module in your main Terraform configuration:

```hcl
module "ec2_autoscaling" {
  source = "./modules/ec2"
  
  # Pass necessary variables here
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  # ... other variables ...
}
```

3. Run `terraform init`, `terraform plan`, and `terraform apply` to create the resources.

## Customization

- Adjust scaling thresholds, instance types, etc. in the `variables.tf` file.
- Define additional policies or alarms in the `main.tf` file as needed.

## Considerations

- When changing scaling policies, consider the balance between cost and performance.
- Thoroughly test in a non-production environment before applying to production.

## Future Improvements

- Add scaling policies based on various metrics (e.g., memory usage, network traffic)
- Consider implementing predictive scaling