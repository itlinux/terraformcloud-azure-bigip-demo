#do


resource bigip_do  do-01 {
     depends_on = [azurerm_virtual_machine_extension.f5vm01-run-startup-cmd]
     do_json = data.template_file.vm01_do_json.rendered
     provider = bigip.one
 }
 resource bigip_do  do-02 {
     depends_on = [azurerm_virtual_machine_extension.f5vm02-run-startup-cmd]
     do_json = data.template_file.vm02_do_json.rendered
     provider = bigip.two
 }