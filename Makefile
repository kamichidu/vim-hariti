MAKE=make

all: main

main:
	${MAKE} -C bin/

prepare:
	pushd `go env GOROOT`/src;\
	GOOS=windows GOARCH=amd64 ./make.bash --no-clean >/dev/null;\
	GOOS=windows GOARCH=386   ./make.bash --no-clean >/dev/null;\
	GOOS=darwin  GOARCH=amd64 ./make.bash --no-clean >/dev/null;\
	GOOS=darwin  GOARCH=386   ./make.bash --no-clean >/dev/null;\
	GOOS=linux   GOARCH=amd64 ./make.bash --no-clean >/dev/null;\
	GOOS=linux   GOARCH=386   ./make.bash --no-clean >/dev/null;\
	popd
