resource bigip_as3  as3-example {
     as3_json = data.template_file.as3_json.rendered
     provider = bigip.one
}

resource bigip_as3  as3-mgmt {
     depends_on = [ bigip_as3.as3-example ]
     as3_json = data.template_file.as3_2_json.rendered
     provider = bigip.one
}