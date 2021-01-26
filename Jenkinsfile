pipeline {
    agent any
    stages {

        stage('Get imas/ual') {
            steps {
                script{
                    docker.withRegistry('https://rhus-71.man.poznan.pl', 'docker-credentials'){
                        def image = docker.image('imas/ual')
                        image.pull()
                        sh 'docker tag rhus-71.man.poznan.pl/imas/ual imas/ual'
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
                        docker.build('catalogqt')
                        docker.build('catalogqt/updateprocess', '--target updateprocess')
                        docker.build('catalogqt/server', '--target server')
                        docker.build('catalogqt/db', '--target db')
                        docker.build('catalogqt/inotify', '--target inotify')
                        docker.build('catalogqt/dashboard', '--target dashboard')

                    }
                }
            }
        }
    }
}