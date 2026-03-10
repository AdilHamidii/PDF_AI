FROM public.ecr.aws/lambda/python:3.12

# Install TeX Live (minimal — just pdflatex + common packages)
RUN dnf install -y texlive-latex texlive-collection-fontsrecommended texlive-collection-latexrecommended && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Pre-generate pdflatex format file so it works in read-only Lambda
RUN fmtutil-sys --all 2>/dev/null || true

# Set TEXMFVAR to /tmp so pdflatex can write temp files at runtime
ENV TEXMFVAR=/tmp/texmf-var
ENV TEXMFCONFIG=/tmp/texmf-config
ENV HOME=/tmp

# Copy function code
COPY lambda_function.py ${LAMBDA_TASK_ROOT}/

# Lambda handler
CMD ["lambda_function.handler"]
