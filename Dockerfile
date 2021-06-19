FROM pytorch/pytorch:1.9.0-cuda11.1-cudnn8-runtime

RUN apt-get update && apt-get install -y openssh-server curl vim net-tools
RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
# Add ENV from main ENV
RUN echo 'export $(cat /proc/1/environ |tr '\0' '\n' | xargs)' | tee -a /root/.profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
