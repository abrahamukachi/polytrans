# polytrans
## A simple Polymer-Starter-Kit translator using Google Translate
This tool translates your PSK(**Polymer-Starter-Kit**) App into **50 different languages**, using a translation engine such as Google Translate and depends on **Translate Shell**(formerly Google Translate CLI). It is based on the amazing **<i18n-msg>** polymer element created by [Eric Bidelman](https://github.com/ebidel), for translation purposes.

I highly recommend checking out this element(**<i18n-msg>**) on [Ebidel's Github Page](https://ebidel.github.io/i18n-msg/components/i18n-msg/), if you still have troubles translating your App or using polytrans.

**polytrans** requires at least one file in your **app/locales** directory. For example, app/locales/[*<file-name>*].json. By default, polytrans' original language is set to '`en`' (English)
If your App's original or main language is in a different language other than English, say Spanish ('`es`'),
just use the **--set-orig-lang** option, to update it.

### ORIGINAL LANGUAGE SETUP
Let's say you want to change your current original language from `English(`**en**`)` to `french(`**fr**`)`:

#### Option #1 - `via terminal`
```bash

  $ ./polytrans.sh --set-orig-lang fr

```

#### Option #2 - `via an editor`
* Go to polytrans home directory located in you PSK App

```bash

  $ cd app/bower_components/polytrans

```

* Open the `.config.xml` file using your prefered editor. I recommend **nano**.

```bash
  $ nano .config.xml
```
Your modified .config.xml file should look like this:

```bash

  <?xml version="1.0" encoding="iso-8859-1"?>

  <polytrans-config>
      <version>0.0.3</version>
      <original-language>fr</original-language>
  </polytrans-config>

```
:warning: **Important**: Save the file (or **Ctrl-S**) and Voila! **:)**

### EXAMPLES
#### Translating Your PSK App
```bash

  $ ./polytrans.sh

```
Translates your PSK App into at least 50 languages and opens a file manager(nautilus) containing all translated files, when done. (default:yes)

```bash

  $ ./polytrans.sh es

```
Translates App from your original language into `Spanish`(**es**))

```bash

  $ ./polytrans.sh {es:fr:it}

```
Translate App into `Spanish`(**es**), `French`(**fr**) and `italian`(**it**)


#### Bower Install
```bash

  $ bower install --save Abilasco/polytrans

```
Saves polytrans files in **bower_components** `folder` of your *PSK App*.


```bash

  $ cd app/bower_components/polytrans

```
Sends you to polytrans `main`(home) directory


```bash

  $ chmod +x polytrans.sh

```
Makes **polytrans** an executable program(`file`)

### DESTINATION
Translated files are saved in your **app/locales/polytrans-updates/**`[<current-date>]` directory, by default. This folder will be created automatically, if it doesn't exist. To save the current translated files in different directory, run:

```bash

  $ ./polytrans.sh  /home/name/Desktop

```

### DEPENDENCIES
- **Translate Shell** - Translate Shell (formerly Google Translate CLI) is a command-line translator powered by Google Translate (default), Bing Translator, and Yandex.Translate. It gives you easy access to one of these translation engines your terminal - [Github link](https://github.com/soimort/translate-shell)

### OPTIONS
* **--set-orig-lang**
Set a new original language and exit.

* **--show-cur-orig-lang**
Print the current original language and exit.

* **-v**, **-V**, **--version**
Print version and exit.

* **-?**, **-h**, **-H**, **--help**
Print help message and exit.

* **-m**, **-M**, **--man**
Show man page and exit.

* **-l**, **-L**, **--languages**
Print all supported 50 languages and codes, in a reference table and exit. Names of languages are displayed in their endonyms (language name in the language itself) and the current selected original language is `highlighted`.

### COPYRIGHT
- Copyright © 2013 Free Software Foundation, Inc.  License GPLv3+: [GNU GPL version 3 or later]( <http://gnu.org/licenses/gpl.html>). This is free software: you are free to change and redistribute it. There is NO WARRANTY, to the extent permitted by law.

## SEE ALSO
- **polymig (1)**
