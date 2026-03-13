# Known Bugs

This Bugs / Error are allready known, dont report it:


## Console power reading can be incorrect on some GPUs

- **Status:** Open
- **Component:** Console logs (`GPU status output`)
- **Description:** On some GPUs, the power value shown in console output is wrong.
  - Example: **NVIDIA GeForce GTX 1080 Ti** may show around **70 W** in console, while real value is around **130 W**.
- **Notes:** The **frontend/dashboard** shows the correct power value for the same device.
