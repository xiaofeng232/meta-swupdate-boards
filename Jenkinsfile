pipeline {
    agent { node { label 'big-node' } }

    options {
        // 替换 throttleJobProperty 为 rateLimitBuilds
        rateLimitBuilds(
            throttle: [count: 1, durationName: 'hour', userBoost: true]
        )
        timeout(time: 8, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '20'))
    }

    environment {
        YOCTO_BRANCH = 'kirkstone'
        DL_DIR = '/home/xiaofeng/Workspace/yocto-taishan/build/downloads'
        SSTATE_DIR = '/home/xiaofeng/Workspace/yocto-taishan/build/sstate-cache'
    }

    stages {
        stage('Checkout Yocto Project') {
            steps {
                git branch: "${YOCTO_BRANCH}",
                    credentialsId: 'gitlab-pat',
                    poll: false, // 禁用轮询，依赖 Webhook 触发
                    url: 'https://github.com/xiaofeng232/yocto-taishan.git'
            }
        }

        stage('Build Production Image') {
            steps {
                sh '''
                    # 传递构建号到 BitBake
                    export BB_ENV_EXTRAWHITE="${BB_ENV_EXTRAWHITE} BUILD_NUMBER"

                    # 初始化构建环境
                    source layers/poky/oe-init-build-env

                    # 设置共享缓存（必须，否则每次构建都重新下载）
                    echo "DL_DIR = '${env.DL_DIR}'" >> conf/local.conf
                    echo "SSTATE_DIR = '${env.SSTATE_DIR}'" >> conf/local.conf

                    # 执行完整镜像构建
                    bitbake my-company-image
                '''
            }
        }

        stage('Build Recovery Image') {
            steps {
                sh '''
                    export BB_ENV_EXTRAWHITE="${BB_ENV_EXTRAWHITE} BUILD_NUMBER"
                    source layers/poky/oe-init-build-env
                    bitbake my-recovery-image
                '''
            }
        }

        stage('Generate SDK') {
            steps {
                sh '''
                    export BB_ENV_EXTRAWHITE="${BB_ENV_EXTRAWHITE} BUILD_NUMBER"
                    source layers/poky/oe-init-build-env
                    bitbake my-company-image -c populate_sdk
                '''
            }
        }

        stage('Archive Artifacts') {
            steps {
                // 归档镜像和 SDK
                archiveArtifacts artifacts: 'build/tmp/deploy/images/**/*.wic.xz',
                                 fingerprint: true
                archiveArtifacts artifacts: 'build/tmp/deploy/sdk/*.sh',
                                 fingerprint: true
            }
        }

        stage('Trigger HIL Testing') {
            steps {
                // 调用硬件在环测试框架
                build job: 'HIL-Testing-Pipeline',
                      parameters: [
                          string(name: 'IMAGE_VERSION', value: "${BUILD_NUMBER}"),
                          string(name: 'IMAGE_PATH', value: "${WORKSPACE}/build/tmp/deploy/images/my-machine/my-company-image.wic.xz")
                      ]
            }
        }
    }

    post {
        success {
            echo "✅ Build #${BUILD_NUMBER} completed successfully!"
            // 发送通知到 Slack/Teams
        }
        failure {
            echo "❌ Build #${BUILD_NUMBER} failed!"
            // 归档失败日志
            archiveArtifacts artifacts: 'build/tmp/log/**/*.log', allowEmptyArchive: true
        }
        always {
            // 清理工作空间（可选，节省磁盘空间）
            cleanWs()
        }
    }
}