FROM pytorch/pytorch:1.9.0-cuda11.1-cudnn8-runtime

RUN apt-get update && apt-get install -y openssh-server curl vim net-tools kmod ceph-common ceph-fuse git
RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
# Add ENV from main ENV
RUN echo 'export $(cat /proc/1/environ |tr '\0' '\n' | xargs)' | tee -a /root/.profile

# Add lab specific information
RUN echo  "Acquire::http::proxy \"http://10.176.51.14:3128\";"  | tee /etc/apt/apt.conf.d/proxy.conf > /dev/null

RUN touch  /etc/ceph/ceph.conf
RUN echo  "[global]\n  fsid = 4255d7cc-81a5-11eb-8f38-a0369fe61953\n  mon_host = 10.176.51.19 10.176.51.16 10.176.51.22" |  tee  /etc/ceph/ceph.conf > /dev/null

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
