// Jenkinsfile (放在 GitHub 仓库根目录)
pipeline {
    agent {
        docker {
            image 'crops/poky:ubuntu-22.04'
            args '-v /mnt/sstate-cache:/sstate-cache -v /mnt/downloads:/downloads'
        }
    }

    triggers {
        githubPush()  // GitHub push 触发
    }

    options {
        timeout(time: 4, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    environment {
        // GitHub 凭据
        GITHUB_TOKEN = credentials('github-pat')
        // Yocto 构建参数
        MACHINE = 'raspberrypi4-64'
        KAS_FILE = 'kas/kas-poky-taishan.yml'
        SSTATE_DIR = '/sstate-cache'
        DL_DIR = '/downloads'
        // 并行构建
        BB_NUMBER_THREADS = '16'
        PARALLEL_MAKE = '-j16'
    }

    stages {
        stage('检出代码') {
            steps {
                checkout scmGit(
                    branches: [[name: '*/${BRANCH_NAME}']],
                    extensions: [
                        cleanBeforeCheckout(),
                        pruneStaleBranches()
                    ],
                    userRemoteConfigs: [[
                        url: 'https://github.com/your-org/yocto-taishan.git',
                        credentialsId: 'github-pat'
                    ]]
                )
            }
        }

        stage('环境检查') {
            steps {
                sh '''
                    echo "=== 检查 GitHub 连接 ==="
                    git remote -v

                    echo "=== 检查磁盘空间 ==="
                    df -h .

                    echo "=== 检查 sstate 缓存 ==="
                    ls -lh ${SSTATE_DIR} || echo "sstate 缓存为空"
                '''
            }
        }

        stage('主镜像构建') {
            steps {
                sh """
                    # 清理锁文件
                    find . -name "*.lock" -delete 2>/dev/null || true

                    # 执行构建
                    ./scripts/Gen-yocto-taishan
                """
            }
            post {
                failure {
                    sh "echo '构建失败，查看日志: ${BUILD_URL}console'"
                }
            }
        }

        stage('生成 SDK') {
            when {
                anyOf {
                    branch 'main'
                    branch 'release/*'
                }
            }
            steps {
                sh """
                    cd build
                    kas shell ${KAS_FILE} -c "bitbake -c populate_sdk core-image-minimal"
                """
            }
        }

        stage('构建 SWU 更新包') {
            steps {
                sh """
                    kas build kas/kas-poky-swupdate.yml
                """
            }
        }

        stage('上传制品到 GitHub Packages') {
            when {
                branch 'main'
            }
            steps {
                sh '''
                    # 设置 GitHub 凭据
                    echo "${GITHUB_TOKEN}" | docker login ghcr.io -u ${GITHUB_USERNAME} --password-stdin

                    # 创建容器镜像并推送
                    cd build/tmp/deploy/images/${MACHINE}
                    tar -cvf yocto-image.tar core-image-minimal-raspberrypi4-64.wic.bz2
                    docker import yocto-image.tar ghcr.io/${GITHUB_USERNAME}/yocto-image:${BUILD_NUMBER}
                    docker push ghcr.io/${GITHUB_USERNAME}/yocto-image:${BUILD_NUMBER}
                '''
            }
        }

        stage('自动化测试') {
            parallel {
                stage('QEMU 启动测试') {
                    steps {
                        sh '''
                            cd build
                            kas shell ${KAS_FILE} -c "runqemu ${MACHINE} nographic slirp qemuparams='-m 512'"
                        '''
                    }
                }
                stage('静态分析') {
                    steps {
                        sh """
                            # 检查层依赖
                            kas check ${KAS_FILE}

                            # 生成许可证报告
                            cd build
                            bitbake -c report_license core-image-minimal
                        """
                    }
                }
            }
        }

        stage('更新 GitHub 状态') {
            steps {
                githubNotify(
                    status: 'SUCCESS',
                    description: "构建成功: ${BUILD_NUMBER}",
                    context: 'Jenkins/Yocto-Build'
                )
            }
            post {
                failure {
                    githubNotify(
                        status: 'FAILURE',
                        description: "构建失败: ${BUILD_NUMBER}",
                        context: 'Jenkins/Yocto-Build'
                    )
                }
            }
        }

        stage('归档制品') {
            steps {
                script {
                    def imageDir = "build/tmp/deploy/images/${MACHINE}"

                    // 归档 WIC 镜像
                    archiveArtifacts artifacts: "${imageDir}/*.wic.bz2", fingerprint: true

                    // 归档 SWU 更新包
                    archiveArtifacts artifacts: "${imageDir}/*.swu", allowEmptyArchive: true

                    // 归档 SDK
                    archiveArtifacts artifacts: "build/tmp/deploy/sdk/*.sh", allowEmptyArchive: true

                    // 归档许可证和清单
                    archiveArtifacts artifacts: "${imageDir}/*-license.json", allowEmptyArchive: true
                    archiveArtifacts artifacts: "${imageDir}/*.manifest", allowEmptyArchive: true
                }
            }
        }
    }

    post {
        always {
            // 清理工作空间
            cleanWs()
        }

        success {
            // 在 GitHub 提交状态添加评论
            sh """
                curl -X POST -H "Authorization: token ${GITHUB_TOKEN}" \
                  https://api.github.com/repos/${GITHUB_REPO}/commits/${GIT_COMMIT}/comments \
                  -d '{"body":"✅ **Jenkins 构建成功**\\n构建号: ${BUILD_NUMBER}\\n镜像: `${MACHINE}`"}'
            """
        }

        failure {
            sh """
                curl -X POST -H "Authorization: token ${GITHUB_TOKEN}" \
                  https://api.github.com/repos/${GITHUB_REPO}/commits/${GIT_COMMIT}/comments \
                  -d '{"body":"❌ **Jenkins 构建失败**\\n构建号: ${BUILD_NUMBER}\\n查看日志: ${BUILD_URL}console"}'
            """
        }
    }
}