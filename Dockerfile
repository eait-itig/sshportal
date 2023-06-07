# build
FROM golang:1.20 as builder
WORKDIR         /go/src/sshportal
COPY            . ./
RUN             go build -ldflags="-X main.GitSha=$(git rev-parse --short HEAD) -X main.GitTag=$(git describe --tags --always) -extldflags '-static' -w -s" -tags sqlite_omit_load_extension -v -o /go/bin/sshportal

# minimal runtime
# https://github.com/GoogleContainerTools/distroless/blob/main/base/README.md
FROM            gcr.io/distroless/static-debian11:latest
COPY            --from=builder /go/bin/sshportal /bin/sshportal
ENTRYPOINT      ["/bin/sshportal"]
CMD             ["server"]
EXPOSE          2222
HEALTHCHECK     CMD /bin/sshportal healthcheck --wait
