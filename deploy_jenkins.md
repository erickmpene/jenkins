#### Deploy Jenkins Redhat/Centos Packages

[![N|Solid](https://cldup.com/dTxpPi9lDf.thumb.png)](https://nodesource.com/products/nsolid)
#### 1. To use this repository, run the following command: 
```sh
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
```
If you've previously imported the key from Jenkins, the rpm --import will fail because you already have a key. Please ignore that and move on.

#### 2. Install Java and Jenkins
```sh
yum update 
yum install fontconfig java-11-openjdk
yum install jenkins
```
#### 3. Verify if jenkins is running

```sh
systemctl start jenkins
systemctl enable jenkins
systemctl --full status jenkins
```
#### 4. Access to jenkins's Webinterface
```sh
http://Your-Jenkins-server-Ip-Address:8080
```
#### 5. The initialAdminPassword
```sh
cat /var/lib/jenkins/secrets/initialAdminPassword
```
#### 6. install Docker
```sh
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```
#### 7. Assign docker rights to jenkins user
```sh 
usermod -aG docker jenkins 
```
#### 8. If you want to keep your firewall active, then you will have to open ports 8080 and 80
```sh
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --reload
```

#### 9. Best practices

##### 9.1 If you want to see the environment variables available when you deploy a job pipeline, implement the following stage:
```sh
        stage('DEBUG') {
          agent any
          steps {
            script {
              sh '''
                env | sort 
              '''
            }
          }
        }
```
For any information you can visit this website --> [jenkins](https://pkg.jenkins.io/redhat-stable/)
#### Enjoy ! 




