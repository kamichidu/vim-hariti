SRC=../go/hariti.go

all: hariti.x64 hariti.x86 hariti.mac64 hariti.mac32 hariti.win64.exe hariti.win32.exe

hariti.x64: ${SRC}
	GOOS=linux GOARCH=amd64 go build -o hariti.x64 ${SRC}

hariti.x86: ${SRC}
	GOOS=linux GOARCH=386 go build -o hariti.x86 ${SRC}

hariti.mac64: ${SRC}
	GOOS=darwin GOARCH=amd64 go build -o hariti.mac64 ${SRC}

hariti.mac32: ${SRC}
	GOOS=darwin GOARCH=386 go build -o hariti.mac32 ${SRC}

hariti.win64.exe: ${SRC}
	GOOS=windows GOARCH=amd64 go build -o hariti.win64.exe ${SRC}

hariti.win32.exe: ${SRC}
	GOOS=windows GOARCH=386 go build -o hariti.win32.exe ${SRC}
