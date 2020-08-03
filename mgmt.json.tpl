{
    "$schema": "https://raw.githubusercontent.com/F5Networks/f5-appsvcs-extension/master/schema/latest/as3-schema.json",
    "class":"AS3",
    "action":"deploy",
    "persist":true,
    "declaration": { 
        "class": "ADC",
        "schemaVersion": "3.12.0",
        "id": "${uuid}",
        "label": "scca baseline",
        "remark": "example 3.12.0",
        "Common": {
            "class": "Tenant",
            "Shared": {
                "class": "Application",
                "template": "shared",
                "example_response": {
                    "class": "iRule",
                    "iRule": "when HTTP_REQUEST {\n    HTTP::respond 200 content {\n        <html>\n        <head>\n        <title>Health Check</title>\n        </head>\n        <body>\n        System is online.\n        </body>\n        </html>\n        }\n}"
                },
                "WAFPolicy":{
                    "class": "WAF_Policy",
                    "url": "https://raw.githubusercontent.com/Mikej81/f5-securecloud-AS3/master/working/asm/15.1/sccaBaselineASMPolicy.xml"
                },
                "certificate_default": {
                    "class": "Certificate",
                    "certificate": {
                        "bigip": "/Common/default.crt"
                    },
                    "privateKey": {
                        "bigip": "/Common/default.key"
                    }
                },
                "ClientSSL": {
                    "certificates": [
                        {
                            "certificate": "certificate_default"
                        }
                    ],
                    "ciphers": "HIGH",
                    "class": "TLS_Server"
                },
                "AFMRuleList":{
                    "class": "Firewall_Rule_List",
                    "rules": [
                        {
                            "action": "accept",
                            "name": "allow_all",
                            "protocol": "any"
                        }
                    ]
                },
                "AFMPolicy": {
                    "class": "Firewall_Policy",
                    "rules": [
                        {
                            "action": "accept",
                            "loggingEnabled": true,
                            "name": "allow_all",
                            "protocol": "any"
                        },
                        {
                            "action": "accept",
                            "loggingEnabled": true,
                            "name": "deny_all",
                            "protocol": "any"
                        }
                    ]
                    
                },
                "AFMPolicyHTTP": {
                    "class": "Firewall_Policy",
                    "rules": [
                        {
                            "action": "accept",
                            "loggingEnabled": true,
                            "name": "allow_all",
                            "protocol": "any"
                        },
                        {
                            "action": "accept",
                            "loggingEnabled": true,
                            "name": "deny_all",
                            "protocol": "any"
                        }
                    ]
                    
                }
            }
        },
        "mgmt": {
            "class": "Tenant",
            "admin": {
                "class": "Application",
                "template": "generic",
                "rdp_pool": {
                    "members": [
                        {
                            "addressDiscovery": "static",
                            "servicePort": 3389,
                            "serverAddresses": [
                                "10.90.2.98"
                            ]
                        }
                    ],
                    "monitors": [
                        {
                            "bigip": "/Common/tcp_half_open"
                        }
                    ],
                    "class": "Pool"
                },
                "ssh_pool": {
                    "members": [
                        {
                            "addressDiscovery": "static",
                            "servicePort": 22,
                            "serverAddresses": [
                                "10.90.2.99"
                            ]
                        }
                    ],
                    "monitors": [
                        {
                            "bigip": "/Common/tcp_half_open"
                        }
                    ],
                    "class": "Pool"
                },
                "mgmt_health_irule": {
                    "class": "iRule",
                    "iRule": "when HTTP_REQUEST {\n    HTTP::respond 200 content {\n        <html>\n        <head>\n        <title>Health Check</title>\n        </head>\n        <body>\n        System is online.\n        </body>\n        </html>\n        }\n}"
                },
                "mgmt_http": {
                    "policyFirewallEnforced": {
                        "use": "/Common/Shared/AFMPolicy"
                    },
                    "layer4": "tcp",
                    "iRules": [
                        "mgmt_health_irule"
                    ],
                    "securityLogProfiles": [
                        {
                            "bigip": "/Common/local-dos"
                        }
                    ],
                    "translateServerAddress": true,
                    "translateServerPort": true,
                    "class": "Service_HTTP",
                    "profileDOS": {
                        "bigip": "/Common/dos"
                    },
                    "profileHTTP": {
                        "bigip": "/Common/http"
                    },
                    "profileTCP": {
                        "bigip": "/Common/tcp"
                    },
                    "virtualAddresses": [
                        "0.0.0.0"
                    ],
                    "virtualPort": 80,
                    "snat": "none"
                },
                "mgmt_rdp": {
                    "policyFirewallEnforced": {
                        "use": "/Common/Shared/AFMPolicy"
                    },
                    "layer4": "tcp",
                    "pool": "rdp_pool",
                    "securityLogProfiles": [
                        {
                            "bigip": "/Common/local-dos"
                        }
                    ],
                    "translateServerAddress": true,
                    "translateServerPort": true,
                    "class": "Service_TCP",
                    "profileTCP": {
                        "bigip": "/Common/tcp"
                    },
                    "virtualAddresses": [
                        "0.0.0.0"
                    ],
                    "virtualPort": 3389,
                    "snat": "auto"
                },
                "mgmt_ssh": {
                    "policyFirewallEnforced": {
                        "use": "/Common/Shared/AFMPolicy"
                    },
                    "layer4": "tcp",
                    "pool": "ssh_pool",
                    "securityLogProfiles": [
                        {
                            "bigip": "/Common/local-dos"
                        }
                    ],
                    "translateServerAddress": true,
                    "translateServerPort": true,
                    "class": "Service_TCP",
                    "profileDOS": {
                        "bigip": "/Common/dos"
                    },
                    "profileTCP": {
                        "bigip": "/Common/tcp"
                    },
                    "virtualAddresses": [
                        "0.0.0.0"
                    ],
                    "virtualPort": 22,
                    "snat": "auto"
                }
            }
        },    
        "Example": {
            "class": "Tenant",
            "exampleApp": {
                "class": "Application",
                "template": "generic",
                "ExampleIPS": {
                    "policyFirewallEnforced": {
                        "use": "/Common/Shared/AFMPolicy"
                    },
                    "layer4": "tcp",
                    "securityLogProfiles": [
                        {
                            "bigip": "/Common/local-dos"
                        }
                    ],
                    "translateServerAddress": true,
                    "translateServerPort": false,
                    "class": "Service_TCP",
                    "profileDOS": {
                        "bigip": "/Common/dos"
                    },
                    "profileHTTP": {
                        "bigip": "/Common/http"
                    },
                    "profileTCP": {
                        "bigip": "/Common/tcp"
                    },
                    "virtualAddresses": [
                        "10.90.2.0"
                    ],
                    "virtualPort": 0,
                    "snat": "auto",
                    "pool": "IPSPool"
                    
                },
                "ExampleHTTPS": {
                    "policyFirewallEnforced": {
                        "use": "/Common/Shared/AFMPolicyHTTP"
                    },
                    "layer4": "tcp",
                    "securityLogProfiles": [
                        {
                            "bigip": "/Common/local-dos"
                        }
                    ],
                    "translateServerAddress": true,
                    "translateServerPort": true,
                    "class": "Service_HTTPS",
                    "profileDOS": {
                        "bigip": "/Common/dos"
                    },
                    "profileHTTP": {
                        "bigip": "/Common/http"
                    },
                    "serverTLS": "/Common/Shared/ClientSSL",
                    "profileTCP": {
                        "bigip": "/Common/tcp"
                    },
                    "virtualAddresses": [
                        "10.90.2.0/24"
                    ],
                    "virtualPort": 443,
                    "snat": "auto",
                    "policyWAF": {
                        "use": "/Common/Shared/WAFPolicy"
                    },
                    "pool": "JuiceShop"
                },
                "IPSPool": {
                    "members": [
                        {
                            "addressDiscovery": "static",
                            "servicePort": 443,
                            "serverAddresses": [
                                "10.0.20.100"
                            ]
                        }
                    ],
                    "class": "Pool"
                },
                "JuiceShop": {
                    "monitors": [
                        {
                            "bigip": "/Common/http"
                        }
                    ],
                    "members": [
                        {
                            "servicePort": 3000,
                            "addressDiscovery": "consul",
                            "updateInterval": 10,
                            "uri": "http://10.90.2.102:8500/v1/catalog/service/juice"
                          }
                    ],
                    "class": "Pool"
                },
                "DemoAppHttps": {
                    "monitors": [
                        {
                            "bigip": "/Common/https"
                        }
                    ],
                    "members": [
                        {
                            "servicePort": 443,
                            "addressDiscovery": "consul",
                            "updateInterval": 10,
                            "uri": "http://10.90.2.102:8500/v1/catalog/service/juices"
                          }
                    ],
                    "class": "Pool"
                },
                "DemoAppHttp": {
                    "monitors": [
                        {
                            "bigip": "/Common/http"
                        }
                    ],
                    "members": [
                        {
                            "servicePort": 80,
                            "addressDiscovery": "consul",
                            "updateInterval": 10,
                            "uri": "http://10.90.2.102:8500/v1/catalog/service/nginx"
                          }
                    ],
                    "class": "Pool"
                }
            }
    }
    }
}