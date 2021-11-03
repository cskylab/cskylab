package internal

import (
	"log"
	"os"
)

// validateTplPath exists and is a directory
func validateTplPath(TplPath string) {

	fileInfo, err := os.Stat(TplPath)
	if err != nil {
		if os.IsNotExist(err) {
			log.Fatalf("Error: Template directory does not exist, %s", err)
		} else {
			log.Fatalf("Error validating TplPath, %s", err)
		}
	}
	if !fileInfo.IsDir() {
		log.Fatal("Error: TplPath is not a directory")
	}
}

//validateParsePath does not exists
func validateParsePath(ParsePath string) {

	if _, err := os.Stat(ParsePath); os.IsNotExist(err) {
		return
	}
	log.Fatal("Error: Destination directory already exists")
}
