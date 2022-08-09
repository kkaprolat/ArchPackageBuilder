node {
        def app

        state('Clone repository') {
                checkout scm
        }

        stage('Build image') {
                app = docker.build("kay/ArchPackageBuilder:latest")
        }
}
