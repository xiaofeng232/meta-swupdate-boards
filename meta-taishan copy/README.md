# meta-taishan
meta-taishan

# 启动 Web 界面
start-swupdate.sh web
# 或
systemctl start swupdate

# 查看状态
start-swupdate.sh status

# 本地更新
start-swupdate.sh update /data/update.swu

# 确认更新成功（新系统首次启动后）
start-swupdate.sh confirm

# 回滚
start-swupdate.sh rollback
