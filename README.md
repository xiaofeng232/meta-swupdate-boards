# yocto-taishan
> 用于工业控制、IOT设备以及数据采集终端，采用了yocto定制Linux，开发一个通用控制平台。</br>
> 这部分为[taishan](https://quip.com/CahROAF7C6bS/06-Taishan)的详细设计文件,[版本变更记录](CHANGELOG.md)记录了版本的变更.</br>
</br>
[莓派swupdate开发镜像生成配置](./kas/rpi-swupdate-dev.yml)</br>
[莓派swupdate发布配置](./kas/rpi-swupdate.yml)</br>
[莓派swupdate平台镜像配置](./kas/taishan-platform-dev.yml)</br>


## layers
* meta-openembedded
* meta-raspberrypi
* meta-swupdate
* meta-swupdate-boards
* meta-taishan

## SDK生成
* bitbake taishan-base-image -c populate_sdk
* bitbake taishan-base-image -c populate_sdk_ext

## Scripts
### 基础构建（不生成SDK）
```shell
./scripts/Gen-yocto-taishan
```

### 增量构建并生成SDK
```shell
./scripts/Gen-yocto-taishan --sdk
```
### 清理后构建并生成SDK
```shell
./scripts/Gen-yocto-taishan --clean --sdk
```
### 仅清理sstate并生成SDK
```shell
./scripts/Gen-yocto-taishan --cleansstate --sdk
```
### 指定自定义镜像生成SDK
```shell
SDKIMAGE=core-image-full-cmdline ./scripts/Gen-yocto-taishan --sdk
```
## 功能开发与集成验证
* 生成镜像[👌]
* SWupdate在线更新软件
* LINUX RT
* 断点Debug
* OTA/多设备镜像同步
* Modbus
* CAN
* EtherCAT
## 如何生成镜像

### Docker生成rpi-swupdate-dev镜像
```shell
kas-container build ./kas/rpi-swupdate-dev.yml 
```
