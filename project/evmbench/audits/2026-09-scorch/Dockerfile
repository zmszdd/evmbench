FROM evmbench/base:latest
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG BASE_COMMIT=845a58d8f847eb2fa38ade630d438412acb69223
COPY repo-history.bundle /tmp/evmbench-history.bundle
RUN git clone --no-hardlinks /tmp/evmbench-history.bundle "$AUDIT_DIR" \
    && git -C "$AUDIT_DIR" checkout --detach "$BASE_COMMIT" \
    && test "$(git -C "$AUDIT_DIR" rev-parse HEAD)" = "$BASE_COMMIT" \
    && rm -f /tmp/evmbench-history.bundle
RUN if [ -d "$AUDIT_DIR/solc" ]; then find "$AUDIT_DIR/solc" -type f -name 'solc-*' -exec chmod 0755 {} +; fi
COPY agent/instruction.md $AGENT_DIR/instruction.md
WORKDIR $AUDIT_DIR
RUN forge build --skip test && forge build --offline --skip test
RUN rm -rf "$AUDIT_DIR/out" "$AUDIT_DIR/cache"
WORKDIR $AGENT_DIR
