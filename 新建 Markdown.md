# Flight 航班
## Attributes 属性
### keys 关键字
- id:航班ID
- hbh:航班号

### 基础信息
- pass:
- wt:
- revenue:

### 时间
- time1:起飞时间
- time2:到达时间

### 空间
- port1:起飞机场
- port2:到达机场

### 飞机匹配约束
#### 机型限制
- atp:可执行机型限制{0,1,0,1,0}
#### 航班特质限制
- water:航班是否涉水
- high:航班是否涉及高高原

## Methods 方法




# Craft 飞机
## Attributes 属性
### keys 关键字
- id:飞机ID

### 基础信息
- tp:
- seat:
-- water:

### 时间
- stime:

### 空间
- start:
-- base = {}:


# Port 机场
## Attributes 属性
### 物理限制
- atp

### 时间限制
- tw 关闭时间

### 标准过站时间
- [1][2][3][4][5]



