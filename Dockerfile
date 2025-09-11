FROM vllm:r36.4.tegra-aarch64-cu126-22.04-torchvision
RUN pip3 install torchaudio --index-url https://download.pytorch.org/whl/cu126
RUN pip3 install ninja && pip3 install -U xformers --index-url https://download.pytorch.org/whl/cu126
RUN python3 -m xformers.info

ENV HTTP_PROXY=
ENV HTTPS_PROXY=
RUN sed -i 's#http://.*\.ubuntu\.com\|http://archive\.ubuntu\.com#https://mirrors.ustc.edu.cn#g' /etc/apt/sources.list
RUN apt update && apt install tmux vim curl wget sudo -y && apt clean && rm -rf /var/lib/apt/lists/*
RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install

RUN pip3 install faiss-cpu
RUN cd /tmp && git clone --depth=1 https://github.com/jenicek/asmk.git && cd asmk/cython && \
    cythonize *.pyx && cd /tmp && \
    pip3 install /tmp/asmk && \
    rm -rf /tmp/asmk

RUN git clone --depth=1 https://github.com/naver/croco.git /croco && \
    cd /croco/models/curope/ && python3 setup.py build_ext --inplace

RUN pip3 install -v roma matplotlib tqdm opencv-python einops trimesh
RUN pip3 install -v tensorboard "pyglet<2" "huggingface-hub[torch]>=0.22" pillow-heif
RUN pip3 install -v pyrender kapture kapture-localization numpy-quaternion
RUN pip3 install -v gradio scipy

ENV HTTP_PROXY=""
ENV HTTPS_PROXY=""
# RUN apt update && apt install libgl1-mesa-glx libglib2.0-0 libsm6 libxext6 libxrender-dev -y && apt clean && rm -rf /var/lib/apt/lists/*
# RUN pip3 install torchaudio[triton] --index-url https://download.pytorch.org/whl/cu126

ENV LD_LIBRARY_PATH=/usr/local/lib/python3.10/dist-packages/torch/lib:$LD_LIBRARY_PATH
# poselib pycolmap

# ADD dust3r/requirements.txt /naver/must3r/dust3r/requirements.txt
