# !/bin/bash
for file in tools/*; do
    filename=$(basename "$file")
    command -v $filename &> /dev/null || { cp ./tools/$filename /usr/local/bin/ && chmod +x /usr/local/bin/$filename; }
done
# 生成目录
mkdir -p original/geoip original/geosite rule-set/geoip rule-set/geosite sing-box/geoip sing-box/geosite

# 生成 list 目录文件，并解压为 txt 文件
sing-box geosite list -f db/geosite.db | awk '{print $1}' | sort > geosite_categories.list
geosite_unpack_cmd="v2dat unpack geosite -o "original/geosite" $(sed 's/^/-f "/;s/$/"/' geosite_categories.list | tr '\n' ' ') "db/geosite.dat""
eval $geosite_unpack_cmd
sing-box geoip list -f db/geoip.db | awk '{print $1}' | sort > geoip_categories.list
geoip_unpack_cmd="v2dat unpack geoip -o "original/geoip" $(sed 's/^/-f "/;s/$/"/' geoip_categories.list | tr '\n' ' ') "db/geoip.dat""
eval $geoip_unpack_cmd


# txt ==>> yaml
for file in original/geosite/*; do
    filename=$(basename "$file")
    output_file="rule-set/geosite/${filename%.*}.yaml"
    echo "payload:" > $output_file
    while IFS= read -r line; do
        case $line in
            regexp:*)
                echo "  - DOMAIN-REGEX,${line#regexp:}" >> "$output_file"
                ;;
            keyward:*)
                echo "  - DOMAIN-KEYWORD,${line#keyward:}" >> "$output_file"
                ;;
            full:*)
                echo "  - DOMAIN,${line#full:}" >> "$output_file"
                ;;
            *)
                echo "  - DOMAIN-SUFFIX,$line" >> "$output_file"
                ;;
        esac
    done < "$file" &
done

for file in original/geoip/*; do
    filename=$(basename "$file")
    output_file="rule-set/geoip/${filename%.*}.yaml"
    echo "payload:" > $output_file
    while IFS= read -r line; do
        echo "  - IP-CIDR,$line" >> $output_file
    done < "$file" &
done

wait

# yaml ==>> mrs
rm rule-set/geosite/*.mrs rule-set/geoip/*.mrs

for file in rule-set/geosite/*; do
    filename=$(basename "$file")
    (cd rule-set/geosite && mihomo convert-ruleset domain yaml $filename ${filename%.*}.mrs) &
done

for file in rule-set/geoip/*; do
    filename=$(basename "$file")
    (cd rule-set/geoip && mihomo convert-ruleset ipcidr yaml $filename ${filename%.*}.mrs) &
done

wait

# 处理sing-box
rm sing-box/geosite/*.json sing-box/geoip/*.json

# 生成 json 文件
while IFS= read -r category; do
    (cd sing-box/geosite && sing-box geosite export $category -f ../../db/geosite.db) &
done < geosite_categories.list

for file in original/geoip/*; do
    filename=$(basename "$file")
    category=$(echo "$filename" | sed 's/geoip_\(.*\)\.txt/\1/')
    output_file="sing-box/geoip/geoip-${category}.json"
    jq -nR '[inputs] | { "version": 1, "rules": [ { "ip_cidr": . } ] }' < $file > $output_file && \
    sing-box rule-set format $output_file -w &
done
wait

# json ==>> srs
rm sing-box/geosite/*.srs sing-box/geoip/*.srs

for file in sing-box/geosite/*; do
    filename=$(basename "$file")
    (cd sing-box/geosite && sing-box rule-set compile $filename) &
done

for file in sing-box/geoip/*; do
    filename=$(basename "$file")
    (cd sing-box/geoip && sing-box rule-set compile $filename) &
done

wait
rm geoip_categories.list  geosite_categories.list



# 生成目录

# 统计 original/geosite 文件夹中的文本行数并输出到 geosite.md 文件
echo "| 分类 | 行数 | txt | RAW | yaml | mrs | json | srs |" > geosite.md
echo "|--------|------|------|--------|-----|-----|-----|-----|" >> geosite.md
for file in original/geosite/*; do
    filename=$(basename "$file")
    category=$(echo "$filename" | sed 's/geosite_\(.*\)\.txt/\1/')
    line_count=$(wc -l < "$file")
    echo -n "| geosite $category | $line_count | " >> geosite.md
    echo -n "[txt_查看](https://github.com/zhihans/geodata/blob/master/original/geosite/geosite_${category}.txt) | " >> geosite.md
    echo -n "[txt_RAW](https://raw.githubusercontent.com/zhihans/geodata/master/original/geosite/geosite_${category}.txt) |" >> geosite.md
    echo -n "[yaml_查看](https://github.com/zhihans/geodata/blob/master/rule-set/geosite/geosite_${category}.yaml) | " >> geosite.md
    echo -n "[mrs_RAW](https://raw.githubusercontent.com/zhihans/geodata/master/rule-set/geosite/geosite_${category}.mrs) |" >> geosite.md
    echo -n "[json_查看](https://github.com/zhihans/geodata/blob/master/sing-box/geosite/geosite-${category}.json) | " >> geosite.md
    echo -n "[srs_RAW](https://raw.githubusercontent.com/zhihans/geodata/master/sing-box/geosite/geosite-${category}.srs) |" >> geosite.md
    echo "" >> geosite.md
done

# 统计 original/geoip 文件夹中的文本行数并输出到 geoip.md 文件
echo "| 分类 | 行数 | txt | RAW | yaml | mrs | json | srs |" > geoip.md
echo "|--------|------|------|--------|-----|-----|-----|-----|" >> geoip.md
for file in original/geoip/*; do
    filename=$(basename "$file")
    category=$(echo "$filename" | sed 's/geoip_\(.*\)\.txt/\1/')
    line_count=$(wc -l < "$file")
    echo -n "| $category | $line_count | " >> geoip.md
    echo -n "[txt_查看](https://github.com/zhihans/geodata/blob/master/original/geoip/geoip_${category}.txt) | " >> geoip.md
    echo -n "[txt_RAW](https://raw.githubusercontent.com/zhihans/geodata/master/original/geoip/geoip_${category}.txt) |" >> geoip.md
    echo -n "[yaml_查看](https://github.com/zhihans/geodata/blob/master/rule-set/geoip/geoip_${category}.yaml) | " >> geoip.md
    echo -n "[mrs_RAW](https://raw.githubusercontent.com/zhihans/geodata/master/rule-set/geoip/geoip_${category}.mrs) |" >> geoip.md
    echo -n "[json_查看](https://github.com/zhihans/geodata/blob/master/sing-box/geoip/geoip-${category}.json) | " >> geoip.md
    echo -n "[srs_RAW](https://raw.githubusercontent.com/zhihans/geodata/master/sing-box/geoip/geoip-${category}.srs) |" >> geoip.md
    echo "" >> geoip.md
done
