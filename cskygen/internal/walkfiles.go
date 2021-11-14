package internal

import (
	"os"
	"path/filepath"
	"strings"
)

// walkParsePath walks the file tree returning a slice with files
func walkParsePath(ParsePath string) ([]string, error) {
	var files []string
	err := filepath.Walk(ParsePath, func(path string, info os.FileInfo, err error) error {
		// Ignore directories
		if !info.IsDir() {
			// Ignore images directories
			if !strings.Contains(path, "images") {
				// Ignore chart directories
				if !strings.Contains(path, "charts") {
					files = append(files, path)
				}
			}
		}
		return nil
	})
	return files, err
}
