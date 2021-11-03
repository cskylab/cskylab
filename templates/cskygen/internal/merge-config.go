package internal

import (
	"fmt"
	"log"

	"github.com/spf13/viper"
)

func mergeConfig(TplPath, usrConfig string) {
	// Reading Template Config
	viper.SetConfigName(tplConfigFile)
	viper.AddConfigPath(TplPath)
	viper.AddConfigPath(".")

	if err := viper.ReadInConfig(); err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); ok {
			// Config file not found; ignore error if desired
			// log.Fatalf("Error finding tplConfigFile %s", err)
		} else {
			// Config file was found but another error was produced
			log.Fatalf("Error reading tplConfigFile %s", err)
		}
	}
	fmt.Println()
	fmt.Println(msgInfo, "Template default values file:", viper.ConfigFileUsed())

	// Reading User Config
	viper.SetConfigName(usrConfig)

	if err := viper.MergeInConfig(); err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); ok {
			// Config file not found; ignore error if desired
			log.Fatalf("Error finding usrConfig config file %s", err)

		} else {
			// Config file was found but another error was produced
			log.Fatalf("Error reading usrConfig config file %s", err)
		}
	}
	fmt.Println(msgInfo, "Override values file:", viper.ConfigFileUsed())
	fmt.Println()
}
