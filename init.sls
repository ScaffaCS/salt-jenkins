jenkins_group:
  group.present:
    - name: jenkins
    - system: True

jenkins_user:
  user.present:
    - name: jenkins
    - groups:
      - jenkins
    - system: True
    - home: /var/lib/jenkins
    - shell: /bin/bash
    - require:
      - group: jenkins
  file.directory:
    - name: /var/lib/jenkins
    - user: jenkins
    - group: jenkins
    - mode: 0755
    - require:
      - user: jenkins
      - group: jenkins

mod_ssl:
  pkg.installed: []

httpd:
  pkg.installed: []
  service.running:
    - enable: True
    - watch:
      - pkg: httpd
      - file: /etc/httpd/conf/httpd.conf
      - file: /etc/httpd/conf.d/*
      - user: httpd

  user.present:
    - uid: 87
    - gid: 87
    - home: /var/www/html
    - shell: /bin/nologin
    - require:
      - group: httpd
  group.present:
    - gid: 87
    - require:
      - pkg: httpd
      - selinux_httpd

/etc/httpd/conf/httpd.conf:
  file.managed:
    - source: salt://jenkins/files/httpd.conf
    - user: root
    - group: root
    - mode: 644

/etc/httpd/conf.d/apache2-jenkins.conf:
  file.managed:
    - source: salt://jenkins/files/apache2-jenkins.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644

mk_ssl_directory:
  cmd.run:
    - name: 'mkdir -p /etc/ssl/private/'
    - unless:
      - ls /etc/ssl/private/

/etc/ssl/private/wildcard_tvflab_co_uk.key:
  file.managed:
    - contents_pillar: wildcard_key
    - user: root
    - group: root
    - mode: 640
    - requires:
      - httpd

/etc/ssl/certs/wildcard_tvflab_co_uk.crt:
  file.managed:
    - contents_pillar: wildcard_cert
    - user: root
    - group: root
    - mode: 644
    - requires:
      - httpd

java_8_install:
  pkg.installed:
    - name: java-1.8.0-openjdk.x86_64

jenkins_rpm_key:
  cmd.run:
    - name: 'sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key'
    - unless:
      - rpm -q jenkins

jenkins_repo:
  pkgrepo.managed:
    - humanname: Jenkins
    - name: Jenkins-stable
    - baseurl: 'http://pkg.jenkins.io/redhat-stable'
    - gpgcheck: 1
    - requires:
      - jenkins_rpm_key

jenkins_installed:
  pkg.installed:
    - name: jenkins
    - requires:
      - jenkins_repo
      - jenkins_rpm_key
      - java_8_install

jenkins_running:
  service.running:
    - name: jenkins
    - requires:
      - jenkins_installed

selinux_httpd:
  cmd.run:
    - name: 'setsebool -P httpd_can_network_connect true'
    - unless: 'sestatus -b | grep -w "httpd_can_network_connect                   on"'
