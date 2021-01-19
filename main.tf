data "vsphere_datacenter" "dc" {
  name = "dc"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
    name          = "cluster"
    datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = "host"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = "pool"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "template"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
    name             = "terraform-test"
    folder           = "Discovered virtual machine"
    resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
    datastore_id     = data.vsphere_datastore.datastore.id
    firmware         = data.vsphere_virtual_machine.template.firmware
    num_cpus = 2
    memory   = 4096
    guest_id = data.vsphere_virtual_machine.template.guest_id
    scsi_type = data.vsphere_virtual_machine.template.scsi_type

    network_interface {
        network_id   = data.vsphere_network.network.id
        adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
    }
    
    disk {
        label            = "disk0"
        size             = data.vsphere_virtual_machine.template.disks.0.size
        eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
        thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
    }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    # customize {
    #   linux_options {
    #     host_name = "terraform-test"
    #     domain    = "test.internal"
    #   }
    }
}