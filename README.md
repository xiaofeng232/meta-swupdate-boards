# yocto-taishan

>[Yocto-taishan](https://quip.com/CahROAF7C6bS/06-Taishan)的详细设计文件,用于工业控制或者IOT设备以及数据采集终端，采用了yocto定制Linux，开发一个通用控制平台。</br>


[设计文档](https://quip.com/CahROAF7C6bS/Taishan)记录开发过程</br>
[版本变更记录](CHANGELOG.md)记录了版本的变更.</br>


## layers
* meta-openembedded
* meta-raspberrypi
* meta-swupdate
* meta-swupdate-boards
* meta-taishan

## SDK生成

```shell
kas-container build ./taishan-platform-dev.yml -c populate_sdk
kas-container build ./taishan-platform-dev.yml -c populate_sdk_ext
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
