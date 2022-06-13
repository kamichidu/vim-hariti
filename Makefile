MAKE=make
BUILDDIR=./go
BUILDFLAGS=-trimpath

.PHONY: all
all: hariti.x64 hariti.x86 hariti.mac64 hariti.win64.exe hariti.win32.exe

.PHONY: hariti.x64
hariti.x64:
	cd "${BUILDDIR}"; GOOS=linux GOARCH=amd64 go build -o ../bin/hariti.x64 ${BUILDFLAGS} .

.PHONY: hariti.x86
hariti.x86:
	cd "${BUILDDIR}"; GOOS=linux GOARCH=386 go build -o ../bin/hariti.x86 ${BUILDFLAGS} .

.PHONY: hariti.mac64
hariti.mac64:
	cd "${BUILDDIR}"; GOOS=darwin GOARCH=amd64 go build -o ../bin/hariti.mac64 ${BUILDFLAGS} .

.PHONY: hariti.win64.exe
hariti.win64.exe:
	cd "${BUILDDIR}"; GOOS=windows GOARCH=amd64 go build -o ../bin/hariti.win64.exe ${BUILDFLAGS} .

.PHONY: hariti.win32.exe
hariti.win32.exe:
	cd "${BUILDDIR}"; GOOS=windows GOARCH=386 go build -o ../bin/hariti.win32.exe ${BUILDFLAGS} .

.PHONY: pre
pre:
	pushd "$(go env GOROOT)/src";\
	GOOS=windows GOARCH=amd64 ./make.bash --no-clean >/dev/null;\
	GOOS=windows GOARCH=386   ./make.bash --no-clean >/dev/null;\
	GOOS=darwin  GOARCH=amd64 ./make.bash --no-clean >/dev/null;\
	GOOS=linux   GOARCH=amd64 ./make.bash --no-clean >/dev/null;\
	GOOS=linux   GOARCH=386   ./make.bash --no-clean >/dev/null;\
	popd


