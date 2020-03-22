#Module      : Label
#Description : This terraform module is designed to generate consistent label names and #              tags for resources. You can use terraform-labels to implement a strict #              naming convention.
module "labels" {
  source = "git::https://github.com/clouddrove/terraform-labels.git?ref=tags/0.12.0"

  name        = local.name
  application = local.application
  environment = local.environment
  label_order = local.label_order
}

locals {
  ebs_iops = local.ebs_volume_type == "io1" ? local.ebs_iops : 0
}


#Module      : EC2
#Description : Terraform module to create an EC2 resource on AWS with Elastic IP Addresses
#              and Elastic Block Store.
resource "aws_instance" "default" {
  count = local.instance_enabled == true ? local.instance_count : 0

  ami                                  = local.ami
  ebs_optimized                        = local.ebs_optimized
  instance_type                        = local.instance_type
  key_name                             = local.key_name
  monitoring                           = local.monitoring
  vpc_security_group_ids               = local.vpc_security_group_ids_list
  subnet_id                            = element(distinct(compact(concat(local.subnet_ids))), count.index)
  associate_public_ip_address          = local.associate_public_ip_address
  disable_api_termination              = local.disable_api_termination
  instance_initiated_shutdown_behavior = local.instance_initiated_shutdown_behavior
  placement_group                      = local.placement_group
  tenancy                              = local.tenancy
  host_id                              = local.host_id
  cpu_core_count                       = local.cpu_core_count
  user_data                            = local.user_data != "" ? base64encode(file(local.user_data)) : ""
  iam_instance_profile                 = join("", aws_iam_instance_profile.default.*.name)
  source_dest_check                    = local.source_dest_check
  ipv6_address_count                   = local.ipv6_address_count
  ipv6_addresses                       = local.ipv6_addresses
  root_block_device {
    volume_size           = local.disk_size
    delete_on_termination = true
  }

  credit_specification {
    cpu_credits = local.cpu_credits
  }

  tags = merge(
    module.labels.tags,
    {

      "Name" = format("%s%s%s", module.labels.id, local.delimiter, (count.index))
    },
    local.instance_tags
  )

  volume_tags = merge(
    module.labels.tags,
    {
      "Name" = format("%s%s%s", module.labels.id, local.delimiter, (count.index))
    }
  )

  lifecycle {
    # Due to several known issues in Terraform AWS provider related to arguments of aws_instance:
    # (eg, https://github.com/terraform-providers/terraform-provider-aws/issues/2036)
    # we have to ignore changes in the following arguments
    ignore_changes = [
      private_ip,
      root_block_device,
      ebs_block_device,
    ]
  }
}

#Module      : EIP
#Description : Provides an Elastic IP resource.
resource "aws_eip" "default" {
  count = local.instance_enabled == true && local.assign_eip_address == true ? local.instance_count : 0

  network_interface = element(aws_instance.default.*.primary_network_interface_id, count.index)
  vpc               = true

  tags = merge(
    module.labels.tags,
    {
      "Name" = format("%s%s%s-eip", module.labels.id, local.delimiter, (count.index))
    }
  )
}

#Module      : EBS VOLUME
#Description : Manages a single EBS volume.
resource "aws_ebs_volume" "default" {
  count = local.instance_enabled == true && local.ebs_volume_enabled == true ? local.instance_count : 0

  availability_zone = element(aws_instance.default.*.availability_zone, count.index)
  size              = local.ebs_volume_size
  iops              = local.ebs_iops
  type              = local.ebs_volume_type

  tags = merge(
    module.labels.tags,
    {
      "Name" = format("%s%s%s", module.labels.id, local.delimiter, (count.index))
    }
  )
}

#Module      : VOLUME ATTACHMENT
#Description : Provides an AWS EBS Volume Attachment as a top level resource, to attach and detach volumes from AWS Instances.
resource "aws_volume_attachment" "default" {
  count = local.instance_enabled == true && local.ebs_volume_enabled == true ? local.instance_count : 0

  device_name = element(local.ebs_device_name, count.index)
  volume_id   = element(aws_ebs_volume.default.*.id, count.index)
  instance_id = element(aws_instance.default.*.id, count.index)
}

#Module      : IAM INSTANCE PROFILE
#Description : Provides an IAM instance profile.
resource "aws_iam_instance_profile" "default" {
  count = local.instance_enabled == true && local.instance_profile_enabled ? 1 : 0
  name  = format("%s%sinstance-profile", module.labels.id, local.delimiter)
  role  = local.iam_instance_profile
}
