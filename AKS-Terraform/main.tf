resource "azurerm_resource_group" "grupo_2demo"{
  name = var.name
  location = var.location

}

resource "azurerm_virtual_network" "vnet_grupo2"{
 name = "vne-grupo2"
 address_space = ["10.0.0.0/16"]
 location =  azurerm_resource_group.grupo_2demo.name
 resource_group_name = azurerm_resource_group.grupo_2demo.name

}

resource "azurerm_subnet" "subnet_grupo2" {
  name = "subnet-grupo2"
  resource_group_name = azurerm_resource_group.grupo_2demo.name
  virtual_network_name = azurerm_virtual_network.vnet_grupo2.name
  address_prefixes = ["10.0.2.0/24"]
}

resource "azurerm_container_registry" "acr" {
  name = "containerRegistryGrupo2"
  resource_group_name = azurerm_resource_group.grupo_2demo.name
  location = azurerm_resource_group.grupo_2demo.location
  sku = "Basic"
  admin_enabled = true  
}

resource "azurerm_kubernetes_cluster" "kubernetescluster"{
  name = "aksdiplomado"
  location = azurerm_resource_group.grupo_2demo.location
  resource_group_name = azurerm_resource_group.grupo_2demo.name
  dns_prefix = "aks1"
  kubernetes_version = "1.22.4"

  default_node_pool {
    name = "default"
    node_count = 1
    vm_size = "Standard D2 v2"
    vnet_subnet_id = azurerm_subnet.subnet_grupo2.id
    enable_auto_scaling = true
    max_count = 3
    min_count = 1
  }

  service_principal {
    client_id = "79e555bb-4fb4-4c71-aa1d-54e3fa772b7d"
    client_secret = "DFm8Q~fcJW2VqCAwAvtLGWfYkI6BUAE1D6zKbcdw"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  role_based_access_control_enabled = true

  # role_based_access_control {
  #   azure_active_directory{
  #     client_app_id =
  #     server_app_id =
  #     server_app_secret =
  #     tenant_id = "0c8da869-eae2-41f6-a58b-c770f96c0c93"
  #   }
  # }

}






