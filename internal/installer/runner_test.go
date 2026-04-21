package installer

import (
	"os"
	"path/filepath"
	"testing"
)

func TestMarkerExistsExpandsRelativeGlobIntoHome(t *testing.T) {
	home := t.TempDir()
	t.Setenv("HOME", home)

	target := filepath.Join(home, ".vst3", "DragonflyHall.vst3")
	if err := os.MkdirAll(target, 0o755); err != nil {
		t.Fatalf("mkdir target: %v", err)
	}

	if !markerExists(".vst3/Dragonfly*.vst3") {
		t.Fatal("expected relative glob marker to match inside HOME")
	}
}
