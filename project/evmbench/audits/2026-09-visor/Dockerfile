FROM evmbench/base:latest
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG BASE_COMMIT=c2fe88a935b27207f59bde386c0bf462c81a2cff
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
