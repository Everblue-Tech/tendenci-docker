FROM ubuntu:18.04

COPY build_assets/install.sh /home/tendenci/install.sh
RUN bash -x ./home/tendenci/install.sh

COPY run_assets/entrypoint.sh /home/tendenci/entrypoint.sh
COPY run_assets/retrieve_settings.py /home/tendenci/retrieve_settings.py
COPY run_assets/bootstrap.sh /home/tendenci/bootstrap.sh
COPY run_assets/symlink.sh /home/tendenci/symlink.sh
RUN chmod +x /home/tendenci/entrypoint.sh
RUN chmod +x /home/tendenci/bootstrap.sh
RUN chmod +x /home/tendenci/symlink.sh

EXPOSE 8000/tcp

ENTRYPOINT [ "/home/tendenci/entrypoint.sh" ]
CMD ["prod"]