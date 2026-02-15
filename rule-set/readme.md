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

~~新支持 mrs 格式 ，`2024-7-27` ，详见 [commit](https://github.com/MetaCubeX/mihomo/commit/4f8a5a5f54ef082dfe02d5db4179e82292ee61d4) 和 [wiki](https://wiki.metacubex.one/config/rule-providers/#format)~~

暂未支持 classical，文件及示例仅占位
```yaml
rule-providers:
  cn:
    type: http
    format: mrs
    behavior: classical
    # path: providers/rule/geosite_cn.mrs
    url: "https://raw.githubusercontent.com/zhihans/geodata/master/rule-set/geosite/geosite_cn.mrs"
    interval: 43200
  cn_ip:
    type: http
    format: mrs
    behavior: classical
    # path: providers/rule/geoip_cn.mrs
    url: "https://raw.githubusercontent.com/zhihans/geodata/master/rule-set/geoip/geoip_cn.mrs"
    interval: 43200
```
