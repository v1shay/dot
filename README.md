<div align="center">
  <img width="400" height="400" alt="dot logo" src="https://github.com/user-attachments/assets/4ff2e3e8-028f-4769-83a3-5ccd8206d5c6" />
</div>

<p align="center">

</p>

<div align="center">
  <img width="192" height="70" alt="dot preview" src="https://github.com/user-attachments/assets/42b83b50-c046-47e8-869e-bb367da2c7e5" />
</div>

---

dot lives quietly in your mac menu bar and lets you cycle through any note one line at a time using hotkeys

## dot actions

| hotkey | action |
|---|---|
| `option + ~` | move to the next line in your note |
| `option + h` | instantly hide/show dot |

---

## features

- instant cycling
- instant hide/show
- persistent local note storage
- lives natively in the menu bar
- works across any app on macOS
- line-by-line teleprompting
- discreet, undetectable

---

## how it works

1. open dot from the menu bar
2. paste or write your note
3. each new line becomes a step
4. press `option + ~` to advance through the note
5. press `option + h` anytime to hide or bring it back

example:

```txt
vishay
is
the best :)
```

---

# setup

## 1. clone the repo

```bash
git clone https://github.com/v1shay/dot.git
cd dot
```

## 2. make sure Swift is available

```bash
swift --version
```

If Swift is not installed, install Apple's command line tools:

```bash
xcode-select --install
```

## 3. run dot

```bash
./script/build_and_run.sh
```

This builds the Swift package, creates `dist/Dot.app`, updates `/Applications/Dot.app` if it already exists, and launches dot.

---

## build the app

```bash
./script/build_and_run.sh --build-only
```

---

## install dot permanently

```bash
./script/install_permanent.sh
```

This installs dot to `/Applications/Dot.app` and registers it to launch at login.
