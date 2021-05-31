pipeline {
    agent any
    stages {

        stage('Get imas/ual') {
            steps {
                script{
                    docker.withRegistry('https://rhus-71.man.poznan.pl', 'docker-credentials'){
                        def image = docker.image('imas/ual:3.30.0-4.8.4')
                        image.pull()
                        sh 'docker tag rhus-71.man.poznan.pl/imas/ual:3.30.0-4.8.4 imas/ual'
                    }
                }
            }
        }

        stage('Build Catalog QT Docker') {
            steps {
                dir('docker-compose/build'){
                    dir('demonstrator-dashboard'){
                        git branch: 'psnc/develop', credentialsId: 'demonstrator-dashboard-credentials', url: 'https://gitlab.com/fair-for-fusion/demonstrator-dashboard'
                    }
                    dir('imas-inotify'){
                        git branch: 'master', url: 'https://github.com/tzok/imas-inotify.git'
                    }
                    dir('catalog_qt_2'){
                        git branch: 'master', credentialsId: 'catalog-qt-credentials', url: 'https://gforge-next.eufus.eu/git/catalog_qt_2'
                    }
                    script{
                        docker.build('catalogqt', '--no-cache .')
                        docker.build('catalogqt/updateprocess', '--target updateprocess .')
                        sh 'docker tag catalogqt/updateprocess registry.apps.paas-dev.psnc.pl/catalog-qt/updateprocess'
                        docker.build('catalogqt/server', '--target server .')
                        sh 'docker tag catalogqt/server registry.apps.paas-dev.psnc.pl/catalog-qt/server'
                        docker.build('catalogqt/db', '--target db .')
                        sh 'docker tag catalogqt/db registry.apps.paas-dev.psnc.pl/catalog-qt/db'
                        docker.build('catalogqt/inotify', '--target inotify .')
                        sh 'docker tag catalogqt/inotify registry.apps.paas-dev.psnc.pl/catalog-qt/inotify'
                        docker.build('catalogqt/dashboard', '--target dashboard .')
                        sh 'docker tag catalogqt/dashboard registry.apps.paas-dev.psnc.pl/catalog-qt/dashboard'
                    }
                }
            }
        }

        stage('Push Catalog QT to image registry') {
            steps {
                script {
                    openshift.withCluster(clusterName:'https://console.paas-dev.psnc.pl/', credential:'oc-credentials') {
                        sh 'docker login -u $(oc whoami) -p $(oc whoami -t) https://registry.apps.paas-dev.psnc.pl/'
                        sh 'docker push registry.apps.paas-dev.psnc.pl/catalog-qt/updateprocess'
                        sh 'docker push registry.apps.paas-dev.psnc.pl/catalog-qt/server'
                        sh 'docker push registry.apps.paas-dev.psnc.pl/catalog-qt/db'
                        sh 'docker push registry.apps.paas-dev.psnc.pl/catalog-qt/inotify'
                        sh 'docker push registry.apps.paas-dev.psnc.pl/catalog-qt/dashboard'
                    }
                }
            }
        }
    }
}