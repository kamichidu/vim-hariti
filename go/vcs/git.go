package git

import (
	"bytes"
	"fmt"
	"os/exec"
)

type Git struct {
}

func NewGit() *Git {
	return &Git{}
}

func (self *Git) Install(url string, path string) error {
	cmd := exec.Command("git", "clone", "--recursive", url, path)
	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	err := cmd.Run()
	if err != nil {
		return fmt.Errorf("%s\n%v", stderr.String(), err)
	}

	return nil
}

func (self *Git) Update(url string, path string) error {
	cmd := exec.Command("git", "pull", "--ff", "--ff-only")
	// working directory
	cmd.Dir = path
	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	err := cmd.Run()
	if err != nil {
		return fmt.Errorf("%s\n%v", stderr.String(), err)
	}

	cmd = exec.Command("git", "submodule", "update", "--init", "--recursive")
	cmd.Stderr = &stderr
	err = cmd.Run()
	if err != nil {
		return fmt.Errorf("%s\n%v", stderr.String(), err)
		return err
	}

	return nil
}
