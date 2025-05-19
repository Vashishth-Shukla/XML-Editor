# XML Editor (Delphi VCL)

A feature-rich, beginner-friendly XML Editor using Delphi VCL.  
Built as a structured, professional-grade application for interview submission and future real-world use.

---

## 🚧 Status

> This project is currently in the **initial setup and planning phase**.  
Implementation will follow step-by-step development, keeping modularity and maintainability in focus.

---

## 🔮 Planned Features

- [ ] Tree-based view of XML structure
- [ ] Visual CRUD editor for:
  - Attributes
  - Inner text
  - Children nodes
- [ ] Synchronized Raw XML editor
- [ ] Multi-tab file editor
- [ ] File operations (Open, Save, Save As, New)
- [ ] Drag & drop XML file opening
- [ ] Lazy search
- [ ] Dockable panels (Tree, Properties, Editor)
- [ ] Layout customization
- [ ] Settings window
- [ ] Dark/Light mode
- [ ] Clipboard integration
- [ ] Undo/Redo
- [ ] Testing:
  - Unit tests for core logic
  - Basic UI test coverage
- [ ] Future: JSON export, plugin support, remote file access

---

## 📁 Folder Structure

```text
/Project
│   P_XML_Editor.dpr         ← Main project file
│   P_XML_Editor.dproj       ← Delphi project metadata

/Source
├── /Forms
│   └── F_Main.pas           ← Main form (UI shell)
│   └── F_Main.dfm
│
├── /UI
│   └── U_EditorView.pas     ← XML editor (structured mode)
│   └── U_RawXmlView.pas     ← Raw text XML editor
│   └── U_FileTabs.pas       ← Tab control for open files
│   └── U_PropertyPanel.pas  ← Attribute & text editor
│   └── U_FileTreeView.pas   ← File system tree view
│   └── U_XmlTreeView.pas    ← XML structure tree
│
├── /Logic
│   └── U_XmlManager.pas     ← XML loading/saving/manipulation
│   └── U_FileManager.pas    ← File I/O
│   └── U_SearchEngine.pas   ← Lazy search engine
│   └── U_ClipboardHelper.pas
│   └── U_SettingsManager.pas
│
├── /Types
│   └── U_Types.pas          ← Shared types and interfaces
│
/Tests
├── /Unit
│   └── XmlManager_Tests.pas
│   └── FileManager_Tests.pas
│
├── /UI
│   └── UITests_Main.pas     ← Simulated UI tests
│
/Assets
└── icons, themes, sample XMLs, etc.

/Docs
└── README.md, notes, specs
```

---

## 🧠 Development Approach

- Separate **interface** and **implementation** where logical
- Organize code into **clearly defined units**
- Apply **design patterns** where applicable (Builder, Strategy)
- Use **consistent naming conventions** (`F_` for forms, `U_` for units)

---

## ✅ Next Steps

- [ ] Finalize folder structure
- [ ] Create basic XML manager with opening/saving
- [ ] Load and render XML tree
- [ ] Build main UI layout (TreeView, Tabs, Editor)
- [ ] Implement simple attribute editor

---

## 💡 Future Improvements

- [ ] Export to JSON
- [ ] Plugin architecture
- [ ] Syntax highlighting in raw editor
- [ ] Validation (XSD/DTD)
- [ ] Remote file support
- [ ] Bookmarking
- [ ] Clipboard support (copy/paste nodes)
- [ ] User preferences save/load
- [ ] In-app XML template creation

---

## 📄 License

To be decided after submission.

---

## 🛠 Requirements

- Delphi Community Edition or higher
- Windows OS
- Basic understanding of Delphi VCL
