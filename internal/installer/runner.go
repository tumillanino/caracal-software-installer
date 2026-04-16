package installer

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/caracal-os/caracal-software-installer/internal/catalog"
)

type PackageState struct {
	Installed bool
	Available bool
}

type Result struct {
	PackageID   string
	PackageName string
	Success     bool
	Error       error
}

func Detect(pkg *catalog.Package) PackageState {
	state := PackageState{
		Available: len(pkg.Actions) > 0,
	}

	for _, marker := range pkg.InstalledMarkers {
		if markerExists(marker) {
			state.Installed = true
			break
		}
	}

	for _, action := range pkg.Actions {
		if len(action.Exec) == 0 {
			state.Available = false
			return state
		}

		if !commandExists(action.Exec[0]) {
			state.Available = false
			return state
		}

		for _, arg := range action.Exec[1:] {
			if looksLikePath(arg) {
				if _, err := os.Stat(arg); err != nil {
					state.Available = false
					return state
				}
			}
		}
	}

	return state
}

func Run(packages []*catalog.Package) []Result {
	results := make([]Result, 0, len(packages))

	fmt.Println("Caracal Software Installer")
	fmt.Println("==========================")
	fmt.Println()

	for index, pkg := range packages {
		fmt.Printf("[%d/%d] %s\n", index+1, len(packages), pkg.Name)

		var runErr error
		for _, action := range pkg.Actions {
			fmt.Printf("  -> %s\n", action.Title)
			if err := runAction(action); err != nil {
				runErr = err
				break
			}
		}

		result := Result{
			PackageID:   pkg.ID,
			PackageName: pkg.Name,
			Success:     runErr == nil,
			Error:       runErr,
		}
		results = append(results, result)

		if runErr != nil {
			fmt.Printf("  !! %v\n", runErr)
		} else {
			fmt.Println("  OK")
		}

		fmt.Println()
	}

	return results
}

func runAction(action catalog.Action) error {
	cmd := exec.Command(action.Exec[0], action.Exec[1:]...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("%s failed: %w", action.Title, err)
	}

	return nil
}

func markerExists(marker string) bool {
	if strings.ContainsAny(marker, "*?[") {
		matches, err := filepath.Glob(marker)
		return err == nil && len(matches) > 0
	}

	target := marker
	if !filepath.IsAbs(marker) {
		home, err := os.UserHomeDir()
		if err != nil {
			return false
		}
		target = filepath.Join(home, marker)
	}

	if strings.ContainsAny(target, "*?[") {
		matches, err := filepath.Glob(target)
		return err == nil && len(matches) > 0
	}

	_, err := os.Stat(target)
	return err == nil
}

func commandExists(command string) bool {
	if looksLikePath(command) {
		_, err := os.Stat(command)
		return err == nil
	}

	_, err := exec.LookPath(command)
	return err == nil
}

func looksLikePath(value string) bool {
	return strings.Contains(value, string(os.PathSeparator)) || strings.HasPrefix(value, ".")
}
