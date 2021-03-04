
# This code is auto generated and any changes will be lost if it is regenerated.

terraform {
    required_version = ">= 0.12.0"
}

# -- Copyright: Copyright (c) 2020, 2021, Oracle and/or its affiliates.
# ---- Author : Andrew Hopkinson (Oracle Cloud Solutions A-Team)
# ------ Connect to Provider
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# ------ Retrieve Regional / Cloud Data
# -------- Get a list of Availability Domains
data "oci_identity_availability_domains" "AvailabilityDomains" {
    compartment_id = var.compartment_ocid
}
data "template_file" "AvailabilityDomainNames" {
    count    = length(data.oci_identity_availability_domains.AvailabilityDomains.availability_domains)
    template = data.oci_identity_availability_domains.AvailabilityDomains.availability_domains[count.index]["name"]
}
# -------- Get a list of Fault Domains
data "oci_identity_fault_domains" "FaultDomainsAD1" {
    availability_domain = element(data.oci_identity_availability_domains.AvailabilityDomains.availability_domains, 0)["name"]
    compartment_id = var.compartment_ocid
}
data "oci_identity_fault_domains" "FaultDomainsAD2" {
    availability_domain = element(data.oci_identity_availability_domains.AvailabilityDomains.availability_domains, 1)["name"]
    compartment_id = var.compartment_ocid
}
data "oci_identity_fault_domains" "FaultDomainsAD3" {
    availability_domain = element(data.oci_identity_availability_domains.AvailabilityDomains.availability_domains, 2)["name"]
    compartment_id = var.compartment_ocid
}
# -------- Get Home Region Name
data "oci_identity_region_subscriptions" "RegionSubscriptions" {
    tenancy_id = var.tenancy_ocid
}
data "oci_identity_regions" "Regions" {
}
data "oci_identity_tenancy" "Tenancy" {
    tenancy_id = var.tenancy_ocid
}

locals {
#    HomeRegion = [for x in data.oci_identity_region_subscriptions.RegionSubscriptions.region_subscriptions: x if x.is_home_region][0]
    home_region = lookup(
        {
            for r in data.oci_identity_regions.Regions.regions : r.key => r.name
        },
        data.oci_identity_tenancy.Tenancy.home_region_key
    )
}
# ------ Get List Service OCIDs
data "oci_core_services" "RegionServices" {
}
# ------ Get List Images
data "oci_core_images" "InstanceImages" {
    compartment_id           = var.compartment_ocid
}

# ------ Home Region Provider
provider "oci" {
    alias            = "home_region"
    tenancy_ocid     = var.tenancy_ocid
    user_ocid        = var.user_ocid
    fingerprint      = var.fingerprint
    private_key_path = var.private_key_path
    region           = local.home_region
}

# ------ Create Compartment - Root True
# ------ Root Compartment
locals {
    Example_id              = var.compartment_ocid
}

output "ExampleId" {
    value = local.Example_id
}

# ------ Create Virtual Cloud Network
resource "oci_core_vcn" "Exwls_Wlsvcn" {
    # Required
    compartment_id = local.Example_id
    cidr_block     = "10.0.0.0/16"
    # Optional
    dns_label      = "exwlsvcn"
    display_name   = "ExWLS-wlsvcn"
    defined_tags   = {"Mandatory_Tag.CreateDate": "2021-03-03T10:22:21.619Z", "Mandatory_Tag.CreatedBy": "okit.oci.user1"}
}

locals {
    Exwls_Wlsvcn_id                       = oci_core_vcn.Exwls_Wlsvcn.id
    Exwls_Wlsvcn_dhcp_options_id          = oci_core_vcn.Exwls_Wlsvcn.default_dhcp_options_id
    Exwls_Wlsvcn_domain_name              = oci_core_vcn.Exwls_Wlsvcn.vcn_domain_name
    Exwls_Wlsvcn_default_dhcp_options_id  = oci_core_vcn.Exwls_Wlsvcn.default_dhcp_options_id
    Exwls_Wlsvcn_default_security_list_id = oci_core_vcn.Exwls_Wlsvcn.default_security_list_id
    Exwls_Wlsvcn_default_route_table_id   = oci_core_vcn.Exwls_Wlsvcn.default_route_table_id
}


# ------ Create Internet Gateway
resource "oci_core_internet_gateway" "Exwls_Internet_Gateway" {
    # Required
    compartment_id = local.Example_id
    vcn_id         = local.Exwls_Wlsvcn_id
    # Optional
    enabled        = true
    display_name   = "ExWLS-internet-gateway"
    defined_tags   = {"Mandatory_Tag.CreateDate": "2021-03-03T10:22:25.525Z", "Mandatory_Tag.CreatedBy": "okit.oci.user1"}
}

locals {
    Exwls_Internet_Gateway_id = oci_core_internet_gateway.Exwls_Internet_Gateway.id
}

# ------ Create Security List
# ------- Update VCN Default Security List
resource "oci_core_default_security_list" "Exwls_Wls_Ms_Security_List" {
    # Required
    manage_default_resource_id = local.Exwls_Wlsvcn_default_security_list_id
    ingress_security_rules {
        # Required
        protocol    = "6"
        source      = "10.0.4.0/24"
        # Optional
        source_type  = "CIDR_BLOCK"
        tcp_options {
            min = "7003"
            max = "7003"
        }
    }
    ingress_security_rules {
        # Required
        protocol    = "6"
        source      = "10.0.4.0/24"
        # Optional
        source_type  = "CIDR_BLOCK"
        tcp_options {
            min = "7004"
            max = "7004"
        }
    }
    # Optional
    display_name   = "ExWLS-wls-ms-security-list"
    defined_tags   = {"Mandatory_Tag.CreateDate": "2021-03-03T10:22:30.066Z", "Mandatory_Tag.CreatedBy": "okit.oci.user1"}
}

locals {
    Exwls_Wls_Ms_Security_List_id = oci_core_default_security_list.Exwls_Wls_Ms_Security_List.id
}


# ------ Create Security List
resource "oci_core_security_list" "Exwls_Internal_Security_List" {
    # Required
    compartment_id = local.Example_id
    vcn_id         = local.Exwls_Wlsvcn_id
    egress_security_rules {
        # Required
        protocol    = "all"
        destination = "0.0.0.0/0"
        # Optional
        destination_type  = "CIDR_BLOCK"
    }
    ingress_security_rules {
        # Required
        protocol    = "6"
        source      = "10.0.3.0/24"
        # Optional
        source_type  = "CIDR_BLOCK"
    }
    # Optional
    display_name   = "ExWLS-internal-security-list"
    defined_tags   = {"Mandatory_Tag.CreateDate": "2021-03-03T10:22:24.962Z", "Mandatory_Tag.CreatedBy": "okit.oci.user1"}
}

locals {
    Exwls_Internal_Security_List_id = oci_core_security_list.Exwls_Internal_Security_List.id
}


# ------ Create Security List
resource "oci_core_security_list" "Exwls_Bastion_Security_List" {
    # Required
    compartment_id = local.Example_id
    vcn_id         = local.Exwls_Wlsvcn_id
    egress_security_rules {
        # Required
        protocol    = "all"
        destination = "0.0.0.0/0"
        # Optional
        destination_type  = "CIDR_BLOCK"
    }
    ingress_security_rules {
        # Required
        protocol    = "6"
        source      = "0.0.0.0/0"
        # Optional
        source_type  = "CIDR_BLOCK"
        tcp_options {
            min = "22"
            max = "22"
        }
    }
    # Optional
    display_name   = "ExWLS-bastion-security-list"
    defined_tags   = {"Mandatory_Tag.CreateDate": "2021-03-03T10:22:27.235Z", "Mandatory_Tag.CreatedBy": "okit.oci.user1"}
}

locals {
    Exwls_Bastion_Security_List_id = oci_core_security_list.Exwls_Bastion_Security_List.id
}


# ------ Create Security List
resource "oci_core_security_list" "Exwls_Lb_Security_List" {
    # Required
    compartment_id = local.Example_id
    vcn_id         = local.Exwls_Wlsvcn_id
    egress_security_rules {
        # Required
        protocol    = "6"
        destination = "0.0.0.0/0"
        # Optional
        destination_type  = "CIDR_BLOCK"
    }
    ingress_security_rules {
        # Required
        protocol    = "6"
        source      = "10.0.6.0/24"
        # Optional
        source_type  = "CIDR_BLOCK"
        tcp_options {
            min = "443"
            max = "443"
        }
    }
    # Optional
    display_name   = "ExWLS-lb-security-list"
    defined_tags   = {"Mandatory_Tag.CreateDate": "2021-03-03T10:22:27.235Z", "Mandatory_Tag.CreatedBy": "okit.oci.user1"}
}

locals {
    Exwls_Lb_Security_List_id = oci_core_security_list.Exwls_Lb_Security_List.id
}


# ------ Create Security List
resource "oci_core_security_list" "Exwls_Wls_Bastion_Security_List" {
    # Required
    compartment_id = local.Example_id
    vcn_id         = local.Exwls_Wlsvcn_id
    egress_security_rules {
        # Required
        protocol    = "all"
        destination = "0.0.0.0/0"
        # Optional
        destination_type  = "CIDR_BLOCK"
    }
    ingress_security_rules {
        # Required
        protocol    = "all"
        source      = "10.0.6.0/24"
        # Optional
        source_type  = "CIDR_BLOCK"
    }
    # Optional
    display_name   = "ExWLS-wls-bastion-security-list"
    defined_tags   = {"Mandatory_Tag.CreateDate": "2021-03-03T10:22:24.962Z", "Mandatory_Tag.CreatedBy": "okit.oci.user1"}
}

locals {
    Exwls_Wls_Bastion_Security_List_id = oci_core_security_list.Exwls_Wls_Bastion_Security_List.id
}


# ------ Create Security List
resource "oci_core_security_list" "DefaultSecurityListForExwls_Wlsvcn" {
    # Required
    compartment_id = local.Example_id
    vcn_id         = local.Exwls_Wlsvcn_id
    egress_security_rules {
        # Required
        protocol    = "all"
        destination = "0.0.0.0/0"
        # Optional
        destination_type  = "CIDR_BLOCK"
    }
    ingress_security_rules {
        # Required
        protocol    = "6"
        source      = "0.0.0.0/0"
        # Optional
        source_type  = "CIDR_BLOCK"
        tcp_options {
            min = "22"
            max = "22"
        }
    }
    ingress_security_rules {
        # Required
        protocol    = "1"
        source      = "0.0.0.0/0"
        # Optional
        source_type  = "CIDR_BLOCK"
        icmp_options {
            type = "3"
            code = "4"
        }
    }
    ingress_security_rules {
        # Required
        protocol    = "1"
        source      = "10.0.0.0/16"
        # Optional
        source_type  = "CIDR_BLOCK"
        icmp_options {
            type = "3"
        }
    }
    # Optional
    display_name   = "Default Security List for ExWLS-wlsvcn"
    defined_tags   = {"Mandatory_Tag.CreateDate": "2021-03-03T10:22:21.619Z", "Mandatory_Tag.CreatedBy": "okit.oci.user1"}
}

locals {
    DefaultSecurityListForExwls_Wlsvcn_id = oci_core_security_list.DefaultSecurityListForExwls_Wlsvcn.id
}


# ------ Create Route Table
# ------- Update VCN Default Route Table
resource "oci_core_default_route_table" "Exwls_Routetable" {
    # Required
    manage_default_resource_id = local.Exwls_Wlsvcn_default_route_table_id
    route_rules    {
        destination_type  = "SERVICE_CIDR_BLOCK"
        destination       = lookup([for x in data.oci_core_services.RegionServices.services: x if substr(x.name, 0, 3) == "all-lhr-services-in-oracle-services-network"][0], "cidr_block")
        network_entity_id = local.Exwls_Service_Gateway_id
        description       = "Rule 01"
    }
    # Optional
    display_name   = "ExWLS-routetable"
    defined_tags   = {"Mandatory_Tag.CreateDate": "2021-03-03T10:22:30.224Z", "Mandatory_Tag.CreatedBy": "okit.oci.user1"}
}

locals {
    Exwls_Routetable_id = oci_core_default_route_table.Exwls_Routetable.id
    }


# ------ Create Route Table
resource "oci_core_route_table" "DefaultRouteTableForExwls_Wlsvcn" {
    # Required
    compartment_id = local.Example_id
    vcn_id         = local.Exwls_Wlsvcn_id
    route_rules    {
        destination_type  = "CIDR_BLOCK"
        destination       = "0.0.0.0/0"
        network_entity_id = local.Exwls_Internet_Gateway_id
        description       = "Rule 01"
    }
    # Optional
    display_name   = "Default Route Table for ExWLS-wlsvcn"
    defined_tags   = {"Mandatory_Tag.CreateDate": "2021-03-03T10:22:21.619Z", "Mandatory_Tag.CreatedBy": "okit.oci.user1"}
}

locals {
    DefaultRouteTableForExwls_Wlsvcn_id = oci_core_route_table.DefaultRouteTableForExwls_Wlsvcn.id
}


# ------ Get List Service OCIDs
locals {
    Exwls_Service_GatewayServiceId = lookup([for x in data.oci_core_services.RegionServices.services: x if substr(x.name, 0, 3) == "All"][0], "id")
}

# ------ Create Service Gateway
resource "oci_core_service_gateway" "Exwls_Service_Gateway" {
    # Required
    compartment_id = local.Example_id
    vcn_id         = local.Exwls_Wlsvcn_id
    services {
        service_id = local.Exwls_Service_GatewayServiceId
    }
    # Optional
    display_name   = "ExWLS-service-gateway"
    defined_tags   = {"Mandatory_Tag.CreateDate": "2021-03-03T10:22:28.256Z", "Mandatory_Tag.CreatedBy": "okit.oci.user1"}
}

locals {
    Exwls_Service_Gateway_id = oci_core_service_gateway.Exwls_Service_Gateway.id
}

# ------ Create Subnet
# ---- Create Public Subnet
resource "oci_core_subnet" "Exwls_Lbprist1" {
    # Required
    compartment_id             = local.Example_id
    vcn_id                     = local.Exwls_Wlsvcn_id
    cidr_block                 = "10.0.4.0/24"
    # Optional
    display_name               = "ExWLS-lbprist1"
    dns_label                  = "lbprist1slwxe"
    security_list_ids          = [local.Exwls_Lb_Security_List_id]
    route_table_id             = local.DefaultRouteTableForExwls_Wlsvcn_id
    dhcp_options_id            = local.Exwls_Wlsvcn_dhcp_options_id
    prohibit_public_ip_on_vnic = true
    defined_tags               = {"Mandatory_Tag.CreateDate": "2021-03-03T10:22:30.816Z", "Mandatory_Tag.CreatedBy": "okit.oci.user1"}
}

locals {
    Exwls_Lbprist1_id              = oci_core_subnet.Exwls_Lbprist1.id
    Exwls_Lbprist1_domain_name     = oci_core_subnet.Exwls_Lbprist1.subnet_domain_name
}

# ------ Create Subnet
# ---- Create Public Subnet
resource "oci_core_subnet" "Exwls_Wl_Subnet" {
    # Required
    compartment_id             = local.Example_id
    vcn_id                     = local.Exwls_Wlsvcn_id
    cidr_block                 = "10.0.3.0/24"
    # Optional
    display_name               = "ExWLS-wl-subnet"
    dns_label                  = "wlsubnetslwxe"
    security_list_ids          = [local.Exwls_Internal_Security_List_id,local.Exwls_Wls_Bastion_Security_List_id,local.Exwls_Wls_Ms_Security_List_id]
    route_table_id             = local.Exwls_Routetable_id
    dhcp_options_id            = local.Exwls_Wlsvcn_dhcp_options_id
    prohibit_public_ip_on_vnic = true
    defined_tags               = {"Mandatory_Tag.CreateDate": "2021-03-03T10:22:30.901Z", "Mandatory_Tag.CreatedBy": "okit.oci.user1"}
}

locals {
    Exwls_Wl_Subnet_id              = oci_core_subnet.Exwls_Wl_Subnet.id
    Exwls_Wl_Subnet_domain_name     = oci_core_subnet.Exwls_Wl_Subnet.subnet_domain_name
}

# ------ Create Subnet
# ---- Create Public Subnet
resource "oci_core_subnet" "Exwls_Bsubnet" {
    # Required
    compartment_id             = local.Example_id
    vcn_id                     = local.Exwls_Wlsvcn_id
    cidr_block                 = "10.0.6.0/24"
    # Optional
    display_name               = "ExWLS-bsubnet"
    dns_label                  = "bsubnet88fe6fd"
    security_list_ids          = [local.Exwls_Wls_Ms_Security_List_id,local.Exwls_Bastion_Security_List_id]
    route_table_id             = local.DefaultRouteTableForExwls_Wlsvcn_id
    dhcp_options_id            = local.Exwls_Wlsvcn_dhcp_options_id
    prohibit_public_ip_on_vnic = false
    defined_tags               = {"Mandatory_Tag.CreateDate": "2021-03-03T10:22:30.912Z", "Mandatory_Tag.CreatedBy": "okit.oci.user1"}
}

locals {
    Exwls_Bsubnet_id              = oci_core_subnet.Exwls_Bsubnet.id
    Exwls_Bsubnet_domain_name     = oci_core_subnet.Exwls_Bsubnet.subnet_domain_name
}
