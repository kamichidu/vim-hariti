package git

import (
	"bytes"
	"fmt"
	"log"
	"os/exec"
)

type Git struct {
}

func NewGit() *Git {
	return &Git{}
}

func run(cmd *exec.Cmd) error {
	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	err := cmd.Run()
	if err != nil {
		log.Printf("Got an error: %s\n---\n%s\n", err, stderr.String())
		return fmt.Errorf("%s\n%v", stderr.String(), err)
	}
	return nil
}

func (self *Git) Install(url string, path string) error {
	log.Printf("Cloning %s to %s\n", url, path)
	cmd := exec.Command("git", "clone", "--recursive", url, path)
	return run(cmd)
}

func (self *Git) Update(_ string, path string) error {
	log.Printf("Pulling in %s", path)
	cmd := exec.Command("git", "pull", "--ff", "--ff-only")
	cmd.Dir = path
	return run(cmd)
}
