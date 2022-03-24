package internal

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
	"text/template"

	"github.com/spf13/viper"
)

// Create receives arguments from cobra and takes care of create command logic.
func Create(configValues, tplPath, parsePath string, silentMode bool) {

	var err error

	// Validations
	validateTplPath(tplPath)
	validateParsePath(parsePath)

	// Show execution options
	fmt.Println()
	fmt.Println(os.Args[0])
	fmt.Println()
	fmt.Println("Create configuration files from template")
	fmt.Println()
	fmt.Println("         Template directory: ", tplPath)
	fmt.Println("      Destination directory: ", parsePath)
	fmt.Println("       Override Values file: ", configValues+".yaml")

	// Prompt for confirmation
	if !silentMode {
		fmt.Println()
		fmt.Println(strings.Repeat("=", len(confirmationMsg)))
		fmt.Println(confirmationMsg)
		bufio.NewReader(os.Stdin).ReadBytes('\n')
		fmt.Println()
	}

	// Merge config files into Viper configuration
	mergeConfig(tplPath, configValues)

	// Create destination directory
	err = os.MkdirAll(parsePath, os.ModePerm)
	if err != nil {
		log.Fatalf("Error creating destination directory, %s", err)
	}

	// Copy template directory into  destination directory
	err = CopyDirectory(tplPath, parsePath)
	if err != nil {
		log.Fatalf("Error in CopyDirectory, %s", err)
	}

	// Remove _values-tpl template configuration file from destination directory
	tplFile := filepath.Clean(parsePath + string(os.PathSeparator) + tplConfigFile + ".yaml")
	err = os.Remove(tplFile)

	if err != nil {
		fmt.Println(err)
		return
	}

	// Remove runbook files with pattern "_rb*.md"
	rbPattern := filepath.Clean(parsePath + string(os.PathSeparator) + "_rb-*.md")

	rbFiles, err := filepath.Glob(rbPattern)
	if err != nil {
		panic(err)
	}
	for _, f := range rbFiles {
		if err := os.Remove(f); err != nil {
			panic(err)
		}
	}

	// Write viper settings to yaml file in parsePath
	fmt.Println()
	fmt.Println(msgInfo, "Resulting override values written to file:", filepath.Clean(parsePath+string(os.PathSeparator)+viperConfigFile+".yaml"))
	fmt.Println()
	viper.WriteConfigAs(filepath.Clean(parsePath + string(os.PathSeparator) + viperConfigFile + ".yaml"))

	// Create file slice from parsePath directory
	files, err := walkParsePath(parsePath)
	if err != nil {
		log.Fatalf("Error in walkParsePath, %s", err)
	}

	// Parsing and executing template resource files
	fmt.Println()
	fmt.Println(msgInfo, "Parsing and executing template resource files")
	fmt.Println()

	for _, file := range files {

		// Parsing template
		fmt.Println(file)
		tpl, err := template.ParseFiles(file)
		if err != nil {
			log.Fatalf("Error parsing template, %s", err)
		}
		// Creating empty file
		f, err := os.Create(file)
		if err != nil {
			log.Fatalf("Error creating file, %s", err)
		}
		defer f.Close()

		// Executing template with values configuration files
		// and write  results to new file.
		err = tpl.Execute(f, viper.AllSettings())
		if err != nil {
			log.Fatalf("Error executing template, %s", err)
		}
	}

	// End of execution
	fmt.Println()
	fmt.Println(msgInfo, os.Args[0], "execution completed")
	fmt.Println()

}
