/*
Copyright © 2021 cSkyLab.com ™

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
package cmd

import (
	"cskygen/internal"
	"log"

	"github.com/spf13/cobra"
)

// createCmd represents the create command
var createCmd = &cobra.Command{
	Use:   "create",
	Short: "Create configuration files from templates",
	Long: `
	Create configuration files from templates`,
	Run: func(cmd *cobra.Command, args []string) {
		// fmt.Println("create called")

		// Parse variables from flags

		configValues, err := cmd.Flags().GetString("values-file")
		if err != nil {
			log.Fatalf("Error reading command flags, %s", err)
		}

		tplPath, err := cmd.Flags().GetString("tpl-dir")
		if err != nil {
			log.Fatalf("Error reading command flags, %s", err)
		}

		parsePath, err := cmd.Flags().GetString("dest-dir")
		if err != nil {
			log.Fatalf("Error reading command flags, %s", err)
		}

		silentMode, err := cmd.Flags().GetBool("quiet")
		if err != nil {
			log.Fatalf("Error reading command flags, %s", err)
		}

		// Call internal procedures
		internal.Create(configValues, tplPath, parsePath, silentMode)

	},
}

func init() {
	rootCmd.AddCommand(createCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// createCmd.PersistentFlags().String("foo", "", "A help for foo")
	createCmd.PersistentFlags().StringP("tpl-dir", "t", "", "Template directory (required)")
	createCmd.MarkPersistentFlagRequired("tpl-dir")
	createCmd.PersistentFlags().StringP("dest-dir", "d", "", "Destination directory (required)")
	createCmd.MarkPersistentFlagRequired("dest-dir")
	createCmd.PersistentFlags().StringP("values-file", "f", "", "Override values file (required) (.yaml extension required on filename but not in flag)")
	createCmd.MarkPersistentFlagRequired("values-file")
	createCmd.PersistentFlags().BoolP("quiet", "q", false, "Quiet mode (optional)")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// createCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")

}
