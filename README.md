# Plugin System

Plugins define HOW resources are processed.

Each plugin is described in JSON format.

---

## Available Plugins

### archive
Extract archive into a target directory.

Definition:
:contentReference[oaicite:0]{index=0}

---

### deployable-archive
Extract archive and recursively process unpacked content.

Definition:
:contentReference[oaicite:1]{index=1}

---

### file
Install file with permissions.

Definition:
:contentReference[oaicite:2]{index=2}

---

### symlink
Create a forced symbolic link.

Definition:
:contentReference[oaicite:3]{index=3}

---

## Plugin Philosophy

- Plugins should be small.
- Plugins should do one thing.
- Plugins should not assume hidden state.

If you add new plugin types, document them properly.
