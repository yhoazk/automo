FROM fedora

RUN dnf update -y
RUN dnf install -y gcc net-tools tcpdump vim

# Expose a 4 ports for Someip
EXPOSE 5555:5560/tcp
EXPOSE 5550:5554/udp

# Getting the src code in the container
VOLUME ["/vsomeip"]

ADD ["./someip_setup.sh", "/"]
CMD ["ls", "/vsomeip"]# /someip_setup.sh"]
CMD ["ls", "/"]
CMD ["bash", "/someip_setup.sh"]
CMD ["bash"]
