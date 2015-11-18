package main

import (
	"./vcs/git"
	"bufio"
	"errors"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
	"sync"
)

type Bundle struct {
	Id   string
	Path string
	Url  string
}

type Vcs interface {
	Install(string, string) error
	Update(string, string) error
}

func init() {
	log.SetFlags(log.Ldate | log.Ltime | log.Lmicroseconds | log.Lshortfile)
	if file, err := os.OpenFile(filepath.Join(filepath.Dir(os.Args[0]), "../logs/hariti.log"), os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0600); err == nil {
		log.SetOutput(file)
	}
}

func parseLine(line []byte) (Vcs, *Bundle, error) {
	items := strings.SplitN(string(line), "\t", 4)
	if len(items) != 4 {
		return nil, nil, errors.New("Too few arguments.")
	}
	id, vcsName, url, path := items[0], items[1], items[2], items[3]

	log.Printf("Given type is `%s'\n", vcsName)

	var vcs Vcs
	switch vcsName {
	case "git":
		vcs = git.NewGit()
	default:
		return nil, nil, fmt.Errorf("Unknown version control system name: ", vcsName)
	}

	bundle := &Bundle{
		Id:   id,
		Url:  url,
		Path: path,
	}

	return vcs, bundle, nil
}

func isDirectory(path string) bool {
	stat, err := os.Stat(path)
	if err != nil {
		return false
	}

	return stat.IsDir()
}

func main() {
	var wg sync.WaitGroup

	in := bufio.NewScanner(os.Stdin)
	for in.Scan() {
		vcs, bundle, err := parseLine(in.Bytes())
		if err != nil {
			log.Panic(err)
		}

		wg.Add(1)
		go func(vcs Vcs, bundle *Bundle) {
			defer func() {
				fmt.Printf("%s\t<FINISH>\n", bundle.Id)
				wg.Done()
			}()

			fmt.Printf("%s\t<START>\n", bundle.Id)
			if isDirectory(bundle.Path) {
				err := vcs.Update(bundle.Url, bundle.Path)
				if err != nil {
					fmt.Printf("%s\t<ERROR>\t%v\n", bundle.Id, strings.Replace(err.Error(), "\n", "\\n", -1))
				}
			} else {
				err := vcs.Install(bundle.Url, bundle.Path)
				if err != nil {
					fmt.Printf("%s\t<ERROR>\t%v\n", bundle.Id, strings.Replace(err.Error(), "\n", "\\n", -1))
				}
			}
		}(vcs, bundle)
	}
	wg.Wait()
}
