# 常用脚本

## 修改md文件标题层级

```bash

find chapters/ -name "*.md" | xargs -I {} sed -i 's/^# 第/### 第/' {}

```

## 将各chapter文件合成为卷文件

```bash

cd chapters 
for d in `ls -1` ; do 
  find $d -name "*.md" | xargs cat > $d.md
done

```

## 将vols文件 合成为 zml文件

```bash

find vols/ -name "*.md" | xargs cat > zml.md

```


## 将卷名增加到卷文件中

```bash
cd vols
for f in `ls *.md`; do
    base="${f%.md}"
    sed -i "1i ## $base " "$f"
done
```

## 去掉卷名中的-
```
cd vols
find ./ -name "*.md" | xargs -I {} sed -i 's/^## 第\([0-9]\+\)卷-/## 第\1卷 /' {} 

```
