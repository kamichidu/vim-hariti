package git

import (
	"bytes"
	"fmt"
	"log"
	"os"
	"os/exec"
)

type Git struct {
	logger *log.Logger
}

func NewGit() *Git {
	return &Git{
		logger: log.New(os.Stderr, "", log.LstdFlags),
	}
}

func NewGitWithLogger(logger *log.Logger) *Git {
	return &Git{
		logger: logger,
	}
}

func (self *Git) Install(url string, path string) error {
	self.logger.Printf("Cloning %s to %s\n", url, path)

	cmd := exec.Command("git", "clone", "--recursive", url, path)
	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	err := cmd.Run()
	if err != nil {
		self.logger.Printf("Got an error: %s\n---\n%s\n", err, stderr.String())
		return fmt.Errorf("%s\n%v", stderr.String(), err)
	}

	return nil
}

func (self *Git) Update(_ string, path string) error {
	self.logger.Printf("Pulling in %s", path)

	cmd := exec.Command("git", "pull", "--ff", "--ff-only")
	// working directory
	cmd.Dir = path
	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	err := cmd.Run()
	if err != nil {
		self.logger.Printf("Got an error: %s\n---\n%s\n", err, stderr.String())
		return fmt.Errorf("%s\n%v", stderr.String(), err)
	}

	cmd = exec.Command("git", "submodule", "update", "--init", "--recursive")
	cmd.Stderr = &stderr
	err = cmd.Run()
	if err != nil {
		self.logger.Printf("Got an error: %s\n---\n%s\n", err, stderr.String())
		return fmt.Errorf("%s\n%v", stderr.String(), err)
	}

	return nil
}
