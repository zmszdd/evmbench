FROM evmbench/base:latest
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG BASE_COMMIT=690fd31ff2fa4e5200b8e367271341080a4e3fe0
COPY repo-history.bundle /tmp/evmbench-history.bundle
RUN git clone --no-hardlinks /tmp/evmbench-history.bundle "$AUDIT_DIR" \
    && git -C "$AUDIT_DIR" checkout --detach "$BASE_COMMIT" \
    && test "$(git -C "$AUDIT_DIR" rev-parse HEAD)" = "$BASE_COMMIT" \
    && rm -f /tmp/evmbench-history.bundle
COPY agent/instruction.md $AGENT_DIR/instruction.md
WORKDIR $AUDIT_DIR
RUN forge build --skip test && forge build --offline --skip test
RUN rm -rf "$AUDIT_DIR/out" "$AUDIT_DIR/cache"
WORKDIR $AGENT_DIR
