```json
{
  "route": {
    "rule_set": [
      {
        "type": "remote",
        "tag": "geosite-cn",
        "format": "source",
        "url": "https://raw.githubusercontent.com/zhihans/geodata/master/sing-box/geosite/geosite-cn.json",
        "download_detour": "🧣 代理节点",
        "update_interval": "24h0m0s"
      },
      {
        "type": "remote",
        "tag": "geoip-cn",
        "format": "source",
        "url": "https://raw.githubusercontent.com/zhihans/geodata/master/sing-box/geoip/geoip-cn.json",
        "download_detour": "🧣 代理节点",
        "update_interval": "24h0m0s"
      }
    ]
  }
}
```
或使用 srs 格式，详见 [wiki](https://sing-box.sagernet.org/zh/configuration/rule-set/#__tabbed_1_3)
```json
{
  "route": {
    "rule_set": [
      {
        "type": "remote",
        "tag": "geosite-cn",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/zhihans/geodata/master/sing-box/geosite/geosite-cn.srs",
        "download_detour": "🧣 代理节点",
        "update_interval": "24h0m0s"
      },
      {
        "type": "remote",
        "tag": "geoip-cn",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/zhihans/geodata/master/sing-box/geoip/geoip-cn.srs",
        "download_detour": "🧣 代理节点",
        "update_interval": "24h0m0s"
      }
    ]
  }
}
```
