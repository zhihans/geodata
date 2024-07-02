```yaml
rules:
  - RULE-SET,cn,DIRECT
  - RULE-SET,cn_ip,DIRECT

rule-providers:
  cn:
    type: http
    format: yaml
    behavior: classical
    # path: providers/rule/geosite_cn.yaml
    url: "https://raw.githubusercontent.com/zhihans/geodata/master/rule-set/geosite/geosite_cn.yaml"
    interval: 43200
  cn_ip:
    type: http
    format: yaml
    behavior: classical
    # path: providers/rule/geoip_cn.yaml
    url: "https://raw.githubusercontent.com/zhihans/geodata/master/rule-set/geoip/geoip_cn.yaml"
    interval: 43200
```
