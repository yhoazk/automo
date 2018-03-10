FROM fedora

RUN dnf update -y
RUN dnf install -y gcc net-tools tcpdump vim

# Expose a 4 ports for Someip
EXPOSE 5555 5554 5553 5552

# Getting the src code in the container
VOLUME ["/vsompeip"]


ENTRYPOINT ["someip_setup.sh"]
