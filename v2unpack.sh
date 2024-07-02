# !/bin/bash
command -v sing-box &> /dev/null || { cp ./tools/sing-box /usr/local/bin/ && chmod +x /usr/local/bin/sing-box; }
command -v v2dat &> /dev/null || { cp ./tools/v2dat /usr/local/bin/ && chmod +x /usr/local/bin/v2dat; }
cd db && bash download_data.sh && cd ../

# 生成geosite_categories.list文件
sing-box geosite list private -f db/geosite.db | awk '{print $1}' | sort > geosite_categories.list
while IFS= read -r category; do
    v2dat unpack geosite -o "original/geosite" -f "$category" "db/geosite.dat" &
done < geosite_categories.list

# 生成geoip_categories.list文件
sing-box geoip list -f db/geoip.db | awk '{print $1}' | sort > geoip_categories.list
while IFS= read -r category; do
    v2dat unpack geoip -o "original/geoip" -f "$category" "db/geoip.dat" &
done < geoip_categories.list

# 等待所有后台任务完成
wait


# 遍历original geosite文件夹的每个文件
for file in original/geosite/*; do
    filename=$(basename "$file")
    output_file="rule-set/geosite/${filename%.*}.yaml"
    echo "payload:" > $output_file
    # 读取文件内容并根据内容类型进行替换和处理
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

# 遍历original geoip文件夹的每个文件
for file in original/geoip/*; do
    filename=$(basename "$file")
    output_file="rule-set/geoip/${filename%.*}.yaml"
    echo "payload:" > $output_file
    # 读取文件内容并进行替换和处理
    while IFS= read -r line; do
        echo "  - IP-CIDR,$line" >> $output_file
    done < "$file" &
done

wait



# 处理sing-box
mkdir -p sing-box/geosite sing-box/geoip
rm sing-box/geosite/*.json sing-box/geoip/*.json

# 生成geosite_categories.list文件
while IFS= read -r category; do
    (cd sing-box/geosite && sing-box geosite export $category -f ../../db/geosite.db) &
done < geosite_categories.list

# 生成geoip_categories.list文件
for file in original/geoip/*; do
    filename=$(basename "$file")
    category=$(echo "$filename" | sed 's/geoip_\(.*\)\.txt/\1/')
    output_file="sing-box/geoip/geoip-${category}.json"
    jq -nR '[inputs] | { "version": 1, "rules": [ { "ip_cidr": . } ] }' < $file > $output_file && \
    sing-box rule-set format $output_file -w &
done
wait

# 编译为srs文件
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

# 统计 original/geosite 文件夹中的文本行数并输出到 geosite_readme.md 文件
echo "| 分类 | 行数 | txt | RAW | yaml | RAW | json | RAW | srs | RAW |" > geosite_readme.md
echo "|--------|------|------|--------|-----|-----|-----|-----|-----|-----|" >> geosite_readme.md
for file in original/geosite/*; do
    filename=$(basename "$file")
    category=$(echo "$filename" | sed 's/geosite_\(.*\)\.txt/\1/')
    line_count=$(wc -l < "$file")
    echo -n "| geosite $category | $line_count | " >> geosite_readme.md
    echo -n "[txt_查看](https://github.com/zhihans/geodata/blob/master/original/geosite/geosite_${category}.txt) | " >> geosite_readme.md
    echo -n "[txt_RAW](https://raw.githubusercontent.com/zhihans/geodata/master/original/geosite/geosite_${category}.txt) |" >> geosite_readme.md
    echo -n "[yaml_查看](https://github.com/zhihans/geodata/blob/master/rule-set/geosite/geosite_${category}.yaml) | " >> geosite_readme.md
    echo -n "[yaml_RAW](https://raw.githubusercontent.com/zhihans/geodata/master/rule-set/geosite/geosite_${category}.yaml) |" >> geosite_readme.md
    echo -n "[json_查看](https://github.com/zhihans/geodata/blob/master/sing-box/geosite/geosite-${category}.json) | " >> geosite_readme.md
    echo -n "[json_RAW](https://raw.githubusercontent.com/zhihans/geodata/master/sing-box/geosite/geosite-${category}.json) |" >> geosite_readme.md
    echo -n "[srs_查看](https://github.com/zhihans/geodata/blob/master/sing-box/geosite/geosite-${category}.srs) | " >> geosite_readme.md
    echo -n "[srs_RAW](https://raw.githubusercontent.com/zhihans/geodata/master/sing-box/geosite/geosite-${category}.srs) |" >> geosite_readme.md
    echo "" >> geosite_readme.md
done

# 统计 original/geoip 文件夹中的文本行数并输出到 geoip_readme.md 文件
echo "| 分类 | 行数 | txt | RAW | yaml | RAW | json | RAW | srs | RAW |" > geoip_readme.md
echo "|--------|------|------|--------|-----|-----|-----|-----|-----|-----|" >> geoip_readme.md
for file in original/geoip/*; do
    filename=$(basename "$file")
    category=$(echo "$filename" | sed 's/geoip_\(.*\)\.txt/\1/')
    line_count=$(wc -l < "$file")
    echo -n "| $category | $line_count | " >> geoip_readme.md
    echo -n "[txt_查看](https://github.com/zhihans/geodata/blob/master/original/geoip/geoip_${category}.txt) | " >> geoip_readme.md
    echo -n "[txt_RAW](https://raw.githubusercontent.com/zhihans/geodata/master/original/geoip/geoip_${category}.txt) |" >> geoip_readme.md
    echo -n "[yaml_查看](https://github.com/zhihans/geodata/blob/master/rule-set/geoip/geoip_${category}.yaml) | " >> geoip_readme.md
    echo -n "[yaml_RAW](https://raw.githubusercontent.com/zhihans/geodata/master/rule-set/geoip/geoip_${category}.yaml) |" >> geoip_readme.md
    echo -n "[json_查看](https://github.com/zhihans/geodata/blob/master/sing-box/geoip/geoip-${category}.json) | " >> geoip_readme.md
    echo -n "[json_RAW](https://raw.githubusercontent.com/zhihans/geodata/master/sing-box/geoip/geoip-${category}.json) |" >> geoip_readme.md
    echo -n "[srs_查看](https://github.com/zhihans/geodata/blob/master/sing-box/geoip/geoip-${category}.srs) | " >> geoip_readme.md
    echo -n "[srs_RAW](https://raw.githubusercontent.com/zhihans/geodata/master/sing-box/geoip/geoip-${category}.srs) |" >> geoip_readme.md
    echo "" >> geoip_readme.md
done