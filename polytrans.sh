#!/bin/bash -e

# Polytrans v0.0.3
# @author: Ukachi Abraham (AKA Abilasco)
# @email: abrahamukachi@gmail.com
# Report bugs or issues on my Github (https://github.com/abilasco/polytrans/issues)

# echo style format
E_BOLD=1
E_RED=31
E_GREEN=92
E_YELLOW=93
E_CYAN=96
E_WHITE=97
E_AND=";"
E_PAUSE=m
E_START="\e["
E_END="\e[0m"

# Unicode char (symbols)...
U_DONE="\u2714"
U_BULL="\u2022"

# Consts
OK=200

# TODO: Renaming Keys as Ids
# TODO: Make polytrans faster | check comments with M.I.F (Make It Faster)

# func-usage: askAgain [function] [primary-error-message]
# example: askAgain toSetOriginalLanguage "no language specified"
function askAgain () {
  if [[ $2 ]]; then
    log -o -e "$2"
  fi

  log -o "please enter a valid language..."

  # print a list of default(or suppported) 50 languages
  printFileContent --no-info "src/languages/.languages"

  log -o "...or try one of the above languages"
  log -n "Enter language (eg. en): "
  eval "read retypedLang"
  # TODO: check if retypedLang is valid (found in src/languages/available-languages.xml)
  eval "$1 $retypedLang"
}

function read_dom () {
  local IFS=\>
  read -d \< ENTITY CONTENT
  local RET=$?
  TAG_NAME=${ENTITY%% *}
  ATTRIBUTES=${ENTITY#* }
  return $RET
}



# func-usage: getFromXmlFile [file] [tag-name]
# example: getFromXmlFile .config.xml original-language
function getFromXmlFile() {
  local tagName=$2

  while read_dom; do
      if [[ $ENTITY = $tagName ]]; then
      result=$CONTENT
          break
      fi
  done < ${1}

  echo "$result"
}


function1() {
  local count=0
  while read_dom ; do
    # TODO: use regular expressions, to replace this loooong stuff...
    if [[ ${#TAG_NAME} -gt 1 && $TAG_NAME != "/"* && $TAG_NAME != *"?"* && $TAG_NAME != *"--"* && $TAG_NAME != "languages" ]];then
      count=$(($count+1))
    fi
  done < 'src/languages/available-languages.xml'

  echo $count
}

# func-usage: log [type] [message]
# example: log -o "please wait..."
# OPTIONS
#   -o = output
#   -i = info
#   -e = error
#   -n = gets user input
function log () {

  # echo "from echo, 1 is $1 2 is $2"

  local color=$E_WHITE
  local prompt="polytrans</>-"
  local msg=$2


  if [[ $# -gt 1 ]]; then
    sleep 0.2

    if [[ $1 = "-n" ]]; then
      echo -ne "\e[0;1m${prompt}\e[0m $2"
    elif [[ $1 = '-l' ]]; then
      # echo " \$2 is $2"

      # log -i "selectedLanguages are $2"

      IFS=":" read -r -a list <<< $2

      for item in ${list[@]};do
        echo -e "\e[1m${U_BULL} $item -[\e[0m$(getLanguageName $item)\e[1m]\e[0m"
      done

    else

      if [[ $1 = "-i" ]]; then
        color=$E_CYAN
      elif [[ $1 = "-o" ]]; then
        # prompt="-</>polytrans"
        if [[ $2 = "-e" ]]; then
          color=$E_RED
          msg=$3
        else
          color=$E_GREEN
        fi
      fi

      formattedPromp="${E_START}${color}${E_AND}${E_BOLD}${E_PAUSE}${prompt}${E_END} "

      if [[ $2 = $OK ]]; then
        echo -e "$formattedPromp \e[1;92m${U_DONE}\e[0m"
      else
        echo -e $formattedPromp $msg
      fi

      sleep 0.5

    fi

  else
    echo -e $1
  fi


}


function getJsonVal () {
  # Python in Polytrans - The PP Brothers! Hurray!!! :)
  # encode! Really? Why? You gave my +10min of Googling. Why?
    python -c 'import json,sys;obj=json.load(sys.stdin);
try:
  print (obj["'$1'"]["message"]).encode("utf-8");
except:
  print "606"
'
}

function calculate() { awk "BEGIN{print $*}"; }

# translateOne from to
function translateOne () {
  # TODO: check if original-language.json file exists in app/locales | again?

  local languageFrom=$1
  local languageTo=$2
  local progress=0
  local message=""
  local key=""
  local realKey=""
  local realMessage=""
  declare -A ORIGINAL_KEY_MESSAGE_OBJECT
  declare -A TRANSLATED_KEY_MESSAGE_OBJECT
  declare -A ERRORS
  local TOTAL_OBJECT_COUNT=0
  local HALF_OBJECT_COUNT=0
  local errorCount=0
  local languageToName=$(getLanguageName $languageTo)

  # Setting 10 Partitions to false (Initial Value) !important
  # local firstPartIsAvailable=false
  # local secondPartIsAvailable=false
  # local thirdPartIsAvailable=false
  # local fourthPartIsAvailable=false
  # local fifthPartIsAvailable=false
  # local sixthPartIsAvailable=false
  # local seventhPartIsAvailable=false
  # local eightPartIsAvailable=false
  # local ninthPartIsAvailable=false
  # local tenthPartIsAvailable=false

  log -i "\b \e[1m($CURRENT_LANG/$TOTAL_LANG):\e[22m translating App into \e[1m$languageTo(\e[22m\e[1;93m$languageToName\e[0;1m)\e[0m...\r"

  progressBar="-"
  initialTerminalWidth=$(tput cols)

  while [[ progress -ne 100 ]]; do

    # IMPORTANT: [The Brain] - most important part of this tool(polytrans v0.0.3)
    # TODO: change progressBar Color programmatically(according to current[active] state of `$progress`)

    case $progress in

      2 )

        # M.I.F (1/2) - Make It Faster
        # averageLimit=100
        #
        # if [[ $KEYS_COUNT -gt $averageLimit ]]; then
        #   averageLimit=$(($KEYS_COUNT / 10))
        #   echo "KEYS_COUNT is greater than the averageLimit, it is => $KEYS_COUNT and averageLimit is now => $averageLimit"
        # else
        #   echo "KEYS_COUNT is not greater than the averageLimit, it is => $KEYS_COUNT and averageLimit is now => $averageLimit"
        # fi

        # M.I.F (2/3)
        # Creating/Setting partitions availability...
        # case $KEYS_COUNT in
        #   [90-100]* )
        #     tenthPartIsAvailable=true
        #     firstPartLimit=$(($averageLimit * 10))
        #       ;;
        #   [80-90]* )
        #     ninthPartIsAvailable=true
        #     ninthPartLimit=$(($averageLimit * 9))
        #       ;;
        #   [70-80]* )
        #     eightPartIsAvailable=true
        #     firstPartLimit=$(($averageLimit  * 8))
        #       ;;
        #   [60-70]* )
        #     seventhPartIsAvailable=true
        #     firstPartLimit=$(($averageLimit * 7))
        #       ;;
        #   [50-60]* )
        #     sixthPartIsAvailable=true
        #     firstPartLimit=$(($averageLimit * 6))
        #       ;;
        #   [40-50]* )
        #     fifthPartIsAvailable=true
        #     firstPartLimit=$(($averageLimit * 5))
        #       ;;
        #   [30-40]* )
        #     fourthPartIsAvailable=true
        #     firstPartLimit=$(($averageLimit * 4))
        #       ;;
        #   [20-30]* )
        #     thirdPartIsAvailable=true
        #     firstPartLimit=$(($averageLimit * 3))
        #       ;;
        #   [10-20]* )
        #     secondPartIsAvailable=true
        #     firstPartLimit=$(($averageLimit * 2))
        #       ;;
        #   [1-10]* )
        #     firstPartIsAvailable=true
        #     firstPartLimit=$averageLimit
        #       ;;
        #   esac
        ;;
      5 )

        # M.I.F. (3/3)
        # First Partition (1/10)
        # if [[ "$firstPartIsAvailable" = true ]]; then
        #   echo "firstPartLimit is Available $firstPartLimit"
        # else
        #   echo "firstPartLimit is not Available, it is $firstPartLimit"
        # fi



        # Creating Key/Message Object (KEYS_LIST) as ORIGINAL_KEY_MESSAGE_OBJECT...
        for key in ${!KEYS_LIST[@]}; do

          # Getting Corresponding Values(`message`) from Key...
          message=$(getMessage $origFilePath $key)

          # Handling 606-(Bad keyword) Errors
          # if [[ $message = '606' ]]; then
          if [[ $message = "606" ]]; then

            if [[ $key != "message" ]]; then
              ERRORS[$errorCount]=$key
              errorCount=$(($errorCount+1))
            fi

              # else...
              # key[message] error, is a common one
              # TODO: find a way to stop its occurrence


          else
            ORIGINAL_KEY_MESSAGE_OBJECT["$key"]="$message"
            # log -o "key: $key | message: $message"
          fi
        done

        # TODO: Interrupt progress and inform the user about errors, if found.
        # and display options at to how these could be fixed or viewed.

        # Uncomment to print out errors Found @ this point
        # echo "ERRORS FOUND: ${#ERRORS[@]}"
        # for error in ${!ERRORS[@]}; do
        #   echo "error #$error - ${ERRORS[$error]}"
        # done

          ;;
      7 )

          # # FIRST PART (1/10)
          # FIRST_PART_OBJECT["$key"]="$message"
          #
          # # SECOND PART (2/10)
          # FIRST_PART_OBJECT
          #
          #
          # # THIRD PART (3/10)
          # FIRST_PART_OBJECT
          #
          # # FOURTH PART (4/10)
          # FIRST_PART_OBJECT
          #
          # # FIFTH PART (5/10)
          # FIRST_PART_OBJECT
          #
          # # SIXTH PART (6/10)
          # FIRST_PART_OBJECT
          #
          # # SEVENTH PART (7/10)
          # FIRST_PART_OBJECT
          #
          # # EIGHT PART (8/10)
          # FIRST_PART_OBJECT
          #
          # # NINTH PART (9/10)
          # FIRST_PART_OBJECT
          #
          # # TENTH PART (10/10)
          # FIRST_PART_OBJECT
        # fi
        ;;
      15 )
        # Checking the ORIGINAL_KEY_MESSAGE_OBJECT...
        # TODO: Tidy this code snippet(block), later
        # for realKey in ${!ORIGINAL_KEY_MESSAGE_OBJECT[@]}; do
        #   log -o "realKey --> $realKey | realMessage --> ${ORIGINAL_KEY_MESSAGE_OBJECT[$realKey]}"
        # done

        ;;
      50 )

      for realKey in ${!ORIGINAL_KEY_MESSAGE_OBJECT[@]}; do
        realMessage=${ORIGINAL_KEY_MESSAGE_OBJECT[$realKey]}

        # finally!!!
        translatedMessage=$(trans -b {"$languageFrom":"$languageTo"} "$realMessage")

        TRANSLATED_KEY_MESSAGE_OBJECT[$realKey]="$translatedMessage"
        # echo "translatedMessage is $translatedMessage"
      done
      # Translating Half(50%) of the messages into given(user-selected) languageTo...
      # FIRST_HALF_MESSAGES=("${ORIGINAL_KEY_MESSAGE_OBJECT[@]:0:HALF_OBJECT_COUNT}")
      # FIRST_HALF_KEYS=("${ORIGINAL_KEY_MESSAGE_OBJECT[@]:0:HALF_OBJECT_COUNT}")
      #
      # echo "#3 --> ${#FIRST_HALF_KEYS[@]} %% --> ${#FIRST_HALF_MESSAGES[@]}"

      # for index in ${FIRST_HALF_KEYS[@]}; do
      #   log -i "From 1st Half"
      #   log -o "realKey --> ${index} | realMessage --> ${FIRST_HALF_MESSAGES[$index]}"
      # done
        ;;
      75 )
      # Translating the Other Half(50%)...
      # SECOND_HALF_KEYS=("${!ORIGINAL_KEY_MESSAGE_OBJECT[@]:HALF_OBJECT_COUNT:TOTAL_OBJECT_COUNT}")
      # SECOND_HALF_MESSAGES=("${ORIGINAL_KEY_MESSAGE_OBJECT[@]:HALF_OBJECT_COUNT:TOTAL_OBJECT_COUNT}")

      # for index in ${!SECOND_HALF_KEYS[@]}; do
      #   log -i "From 2nd Half"
      #   log -o "realKey --> ${!SECOND_HALF_KEYS[$index]} | realMessage --> ${SECOND_HALF_MESSAGES[$index]}"
      # done
        ;;
      80 )
      # Reformatting or generating json-like syntax as text(`string`)
      # TODO: find a better way to do this!
      translatedJsonString=''

      for key in ${!TRANSLATED_KEY_MESSAGE_OBJECT[@]}; do
        translatedMessage=${TRANSLATED_KEY_MESSAGE_OBJECT[$key]}

        # echo ""
        translatedJsonString+=$(printf '
  "%s": {
    "message": "%s"
  },' "$key" "$translatedMessage")

        # TRANSLATED_KEY_MESSAGE_OBJECT[$realKey]="$translatedMessage"
        # echo "translatedMessage is $translatedMessage"
      done

      translatedJsonString=$(printf '
{
    %s
}' "${translatedJsonString:0:$((${#translatedJsonString} - 1))}")
      # echo $translatedJsonString
        ;;
    95 )
      # Getting Current Date && Saving generated text as a JSON in `../../locales/polytrans-update/[YYYY-MM-DD]` directory
      # TODO: clean this up too
      curDate=$(date +'%Y-%m-%d')

      homePath=$localesPath

      if [[ "$isCustomTargetDirectory" = true ]]; then
        homePath=$customTargetDirectory
      else
        homePath=$localesPath
      fi

      # echo $localesPath

      # echo "isCustomTargetDirectory is $isCustomTargetDirectory | homePath is $homePath | pathToSave is $pathToSave"

      pathToSave="$homePath/polytrans-update/$curDate/"

      saveFile () {
        echo "$translatedJsonString" > $(printf "%s%s.json" "$pathToSave"  "$languageTo")
      }

      if [[ ! -d "$pathToSave" ]];then
        mkdir -p "$pathToSave"
      fi

      saveFile

        ;;
    esac

    terminalWidth=$(tput cols)

    if [[ $terminalWidth -lt $initialTerminalWidth ]]; then
      # refresh area
      clear
      log -i "\b \e[1m($CURRENT_LANG/$TOTAL_LANG):\e[22m translating App into \e[1m$language(\e[22m\e[1;93m$languageName\e[0;1m)\e[0m...\r"
      initialTerminalWidth=$terminalWidth
    fi

    initialTerminalWidth=$terminalWidth


    progressBar="-"

    if [[ $(($terminalWidth-30)) -ne $progressBarWidth ]]; then
      progressBar="-"
    fi

    progressBarWidth=$(($terminalWidth-30))
    progressBg=""
    for (( i = 0; i < ${progressBarWidth}; i++ )); do
      progressBg+="-"
    done

    # formatted progress width
    FPW=$(calculate "($progressBarWidth / 100) * $progress")
    FPW_RESULT=${FPW%.*}

    for (( i = 0; i < ${FPW_RESULT}; i++ )); do
      progressBar+="-"
    done

    log -n "\e[1;${E_CYAN}m[ ${progress}% ] \e[0;1m-│\e[44;8m${progressBg}\e[0;1m│\e[0m\r"
    log -n "\e[1;${E_CYAN}m[ ${progress}% ] \e[0;1m-│\e[106;8m${progressBar} \e[0m\r"

    progress=$((progress+1))
  done

  log -n "\e[30;8m[ ${progress}% ] -│${progressBar}  \e[30;8m│\e[0m\r"
  log -o "\e[1;92m${U_DONE}${U_DONE}\e[0m done"
}


function translateAll () {
  # TODO: calculate ETA


  spTimer=0
  sp="/-\|"
  CURRENT_LANG=1

  beginTranslation () {

    if [[ $CURRENT_LANG -eq 1 ]]; then
      log -o "fetching language..."
      else
        log -o "fetching next language..."
      fi

      echo -n ' '

      # My Spinner Man :)
      while [[ spTimer -lt 50 ]]; do
        echo -ne " \e[1m${sp:spTimer++%${#sp}:1} \e[22m\r"
        sleep 0.1
      done

      echo -ne "\b"
      translateOne $originalLanguage $1

      # sleep 0.5
      CURRENT_LANG=$(($CURRENT_LANG+1))
    # fi

    spTimer=0
  }


  case "$1" in
    -one )
      log -i "\e[${E_CYAN}mPlease wait, we'll be done in a moment...\e[0m"
      TOTAL_LANG=1
      beginTranslation "$oneLanguage"
        ;;
    -user-selected )
      log -i "\e[${E_CYAN}mPlease wait...\e[0m"
      TOTAL_LANG=${#selectedLanguagesArray[@]}
      for lang in ${selectedLanguagesArray[@]};do
        beginTranslation "$lang"
      done
        ;;
    * )
      log -i "\e[${E_CYAN}mNow just relax, 'cos this might take a while...\e[0m"
      TOTAL_LANG=`getAvailableLanguagesCount`
      while read_dom ; do
        lang=$TAG_NAME

        # TODO: use regular expressions or somthing else, to replace this anoyingly loooong stuff...
        if [[ ${#TAG_NAME} -gt 1 && $TAG_NAME != "/"* && $TAG_NAME != *"?"* && $TAG_NAME != *"--"* && $TAG_NAME != "languages" ]];then
          beginTranslation "$lang"
        fi
      done < 'src/languages/available-languages.xml'
        ;;
  esac

  log -o "\e[4mPSK App\e[24m \e[1;${E_GREEN}mTranslation Complete!\e[0m"
  log -o "\e[1;${E_GREEN}m${U_DONE}${U_DONE}${U_DONE}${U_DONE}${U_DONE}${U_DONE}${U_DONE}\e[0m"
  log -o "\e[${E_YELLOW}mOpening translated files in your file manager...\e[0m"
  nautilus "$pathToSave"
  echo -e "\e[${E_CYAN}mThanks again for using '\e[1mpolytrans\e[0;${E_CYAN}m', if you encountered issues go to \e[1mGithub \e[0;1m(\e[${E_GREEN};1mhttps://github.com/abilasco/polytrans/issues\e[0;1m)\e[0m"
  exit 0
}

# Usage: getMessage ../../locales/en.json "app_name"
# $1 - original language path
# $2 - key
function getMessage () {
  echo $(echo $(sed -r 's/^\s*//; s/\s*$//; /^$/d' "$1") | getJsonVal "$2")
}

function goip () {

  for i in ${!KEYS_LIST[@]}; do
      echo "**-> $i"
  done

}

function checkingThisLanguageAvailability () {
  local language=$1
  local languageName=$(getLanguageName $language)

  log -i "checking the availability of \e[1m$language\e[0m..."

  if [[ $(getLanguageAvailability $language) = false ]]; then
    log -o -e "\e[${E_RED};1m$language\e[0m is \e[${E_RED};1mnot a valid language\e[0m or we do not support it, YET \e[${E_RED};1m:(\e[0m"
    exit 0
  elif [[ $language != $originalLanguage ]]; then
    log -o "\e[1;92m${U_DONE}\e[0m \e[1;${E_GREEN}m$newLanguage($languageName) is available\e[0m"
  else
    log -o -e "\e[1;${E_RED}m$language($languageName) is the same as your original language($originalLanguageName)\e[0m"
    exit 0
  fi
}
function translate () {
  originalLanguage=$(getFromXmlFile .config.xml original-language)
  originalLanguageName=$(getLanguageName $originalLanguage)

  isUserSelectedOneLanguage=false
  isUserSelectedLanguages=false

  declare -a selectedLanguagesArray

  if [[ $1 ]]; then

    # echo "\$1 is $1"

    if [[ $1 == "{"* ]];then

      # more than 1 language ?...
      selectedLanguages="${1:1:-1}"
      # log -i "selectedLanguages are $selectedLanguages"

      IFS=":" read -r -a selectedLanguagesArray <<< $selectedLanguages

      for language in ${selectedLanguagesArray[@]};do
        # check the availability of the user-selected languages
        checkingThisLanguageAvailability "$language"
      done

      isUserSelectedLanguages=true
      log -i "Your \e[4mPSK App\e[24m is about to be translated from \e[1m$originalLanguage\e[22m(\e[1m$originalLanguageName\e[22m) into:"
      log -l "$selectedLanguages"
      log -n "Do you want to continue? (Y/n): "

    else
      # just one?
      # checking the availability of this one too, ofcourse... :)
      oneLanguage=$1
      oneLanguageName=$(getLanguageName $oneLanguage)
      checkingThisLanguageAvailability "$oneLanguage"
      isUserSelectedOneLanguage=true
      log -i "Your \e[4mPSK App\e[24m is about to be translated from \e[1m$originalLanguage\e[22m(\e[1m$originalLanguageName\e[22m) into \e[1m$oneLanguage\e[22m(\e[1m$oneLanguageName\e[22m)."
      log -n "Do you want to continue? (Y/n): "
    fi

  else

    log -i "Your \e[4mPSK App\e[24m is about to be translated from \e[1m$originalLanguage\e[22m(\e[1m$originalLanguageName\e[22m) into 50 languages."
    log -n "Do you want to continue? (Y/n): "

  fi


  read answer

  case ${answer^^} in
    N*) exit 0 ;;
    Y* | *)

      log -i "please wait..."
      # log -i "verifying your original language(\e[1m$originalLanguageName\e[0m)..."
      # log -o $OK
      log -i "\e[1;${E_CYAN}mchecking\e[0m [polymer-starter-kit]/\e[1mapp/locales\e[0m, for \e[1m$originalLanguage.json\e[0m...\e[0m"

      # you can edit this url, if you want :)
      localesPath="../../locales"
      origFilePath="$localesPath/$originalLanguage.json"
      # local origFilePath="../../locales/real_en.json"
      # local origFilePath="../../locales/$originalLanguage.json"
      if [[ -f $origFilePath ]]; then
        log -o $OK

        # proceed...
        log -i "\e[1;${E_CYAN}mchecking\e[0m \e[1m$originalLanguage.json\e[0m, for errors...\e[0m"
        # TODO: try/catch-like behavior, to handle errors in user's original file(json)


        # try - here! ------------------

        # Getting all required keys, from the selected json file
        string=$(cat "$origFilePath")
        # echo -e "$string\n\n"

         declare -A KEYS_LIST

          while read key value; do
              [[ -n "$key" ]] && KEYS_LIST["$key"]="$value"
          done < <(sed 's/[\"{}]//g' <<< $string | awk -F: 'BEGIN{RS=","} {print $1" "$2}')

          log -o $OK

          # getMessage

          log -i "\e[1;${E_CYAN}msearching\e[0m for all available keys...\e[0m"

          # Getting the first two keys ...
          firstTwoKeys=""
          local count=0
          for i in ${!KEYS_LIST[@]}; do
            if [[ $count -lt 2 ]]; then
            firstTwoKeys+="$i,"
            fi
            count=$(($count+1))

            # Uncomment the code below, to preview All available messages to `console`
            # message=$(getMessage $origFilePath $i)
            # log -i " message -> \e[1m$message\e[0m"

          done

          KEYS_COUNT="${#KEYS_LIST[@]}"

        # catch - here! ---------------

        if [[ KEYS_COUNT -gt 0 ]]; then
          log -o $OK
          log -o "\e[1m$KEYS_COUNT Keys\e[0m($firstTwoKeys...) \e[1mfound\e[0m!"

          # checking if App should be translated into all 50 languages or user-selected ones...
          if $isUserSelectedOneLanguage; then

            translateAll -one
          elif $isUserSelectedLanguages; then
            translateAll -user-selected
          else
            translateAll
          fi
        else
          # no keys found === file empty
          log -o -e "\e[${E_RED};1mP404:\e[0;${E_RED}m No Keys found!\e[0m"
          echo -e "\e[${E_YELLOW}mWe were unable to find at least one key, from your JSON Object in \e[1m$origFilePath\e[0;${E_YELLOW}m - This file is probably empty or has syntax issues.\e[0m"
          echo -e "\e[${E_CYAN}mTry '\e[1mpolytrans.sh --man\e[0;${E_CYAN}m', for more help or contact us on \e[1mGithub \e[0;1m(\e[${E_GREEN};1mhttps://github.com/abilasco/polytrans/issues\e[0;1m)\e[0m"
        fi

      else
        log -o -e "\e[${E_RED}mno file (\e[1m$origFilePath\e[0;${E_RED}m) found!\e[0m"
        exit 0
      fi

    ;;
  esac

}

function showManPage () {
  log -o "\e[1;${E_CYAN}msearching\e[0m for polytrans man page..."
  local FILE="polytrans.1"
  local MAN_FILE="src/man/$FILE"
  local MAN_FILE_GZ="src/man/$FILE.gz"

  local fileFound=true
  local fileToOpen
  # if src/man directory exists...
  if [[ -f $MAN_FILE_GZ ]]; then
    fileToOpen=$MAN_FILE_GZ
  elif [[  -f $MAN_FILE  ]]; then
    fileToOpen=$MAN_FILE
  elif [[ -f .$FILE ]]; then
    fileToOpen=./.$FILE
  else
    fileFound=false
  fi

  if [[ fileFound ]]; then
    log -o "found 1"
    log -i "opening man page..."
    man $fileToOpen
    log -o "\e[1;92m${U_DONE}${U_DONE}\e[0m done"
  else
      log -o -e "no manual page found"
  fi
}

function getLanguageName () {
  getFromXmlFile ./src/languages/available-languages.xml $1
}

function getLanguageAvailability () {
  _result=false

  if [[ $(getLanguageName $1) ]]; then
    # language is available
    _result=true
  fi

  log $_result
}

function toSetOriginalLanguage () {
  if [[ $# -gt 0 ]]; then

    local file=".config.xml"
    local name="original-language"
    local oldLanguage=$(getFromXmlFile .config.xml "${name}")
    local newLanguage="$1"

    local oldLanguageName=$(getLanguageName "${oldLanguage}")
    local newLanguageName=$(getLanguageName "${newLanguage}")

    log -i "checking the availability of \e[1m$newLanguage\e[0m..."

    if [[ $(getLanguageAvailability $newLanguage) = false ]]; then
      askAgain toSetOriginalLanguage "\e[${E_RED};1m$newLanguage\e[0m is \e[${E_RED};1mnot a valid language\e[0m or we do not support it, YET \e[${E_RED};1m:(\e[0m"
    elif [[ $oldLanguage != $newLanguage ]]; then
      log -o "\e[1;92m${U_DONE}\e[0m \e[1;${E_GREEN}m$newLanguage($newLanguageName) is available\e[0m"
      log -i "configuring polytrans..."
      log -i "setting current original language to \e[0;1m$1\e[0m..."
      sleep 2

      old="<${name}>${oldLanguage}<\/${name}>"
      new="<${name}>${newLanguage}<\/${name}>"

      # log -o "old: $old | new: $new"
      result="ed -s ${file} <<< $',s/$old/$new/g\nw'"
      eval $result

      # updating .languages file...
      # custom styles:
      # initial --> │\e[0m name\t-\t\e[1mid\t\e[22m\e[1;96m│
      # selected --> │\e[0;46;1m English\t-\t\e[1men\t\e[0m\e[1;96m│
      #

      # deselecting the old language...
      # old_1="│0;46;1m ${oldLanguageName}\t-\t\e\[1m${oldLanguage}\t\e\[0m\e\[1;96m│"
      # old_1="│\e\[0;46;1m ${oldLanguageName}\t-\t\e\[1m${oldLanguage}\t\e\[0m\e\[1;96m│"
      # new_1="│\e\[0m ${oldLanguageName}\t-\t\e\[1m${oldLanguage}\t\e\[22m\e\[1;96m│"

      # selecting the new language...
      old_2="│\e\[0m ${newLanguageName}\t-\t\e\[1m${newLanguage}\t\e\[22m\e\[1;96m│"
      new_2="│\e\[0;46;1m ${newLanguageName}\t-\t\e\[1m${newLanguage}\t\e\[0m\e\[1;96m│"

      deselect_data="ed -s src/languages/.languages <<< $',s/0;46;1m/0m/g\nw'"
      select_data="ed -s src/languages/.languages <<< $',s/0m $newLanguageName/0;46;1m $newLanguageName/g\nw'"
      # result_old="ed -s src/languages/.languages <<< $',s/"[+]English"/English/g\nw'"
      # result_new="ed -s src/languages/.languages <<< $',s/$old_2/$new_2/g\nw'"

      # echo result_old is $result_old
      # echo result_new is $result_new
      # echo deselect_data is $deselect_data
      # echo select_data is $select_data


      sleep 1
      log -o $OK

      log -i "saving changes..."

      eval $deselect_data
      eval $select_data
      # eval "$result_old"
      # eval "$result_new"

      log -o "\e[1;92m${U_DONE}${U_DONE}\e[0m done"
    else
      # log -o -e "old and new languages are the same"
      askAgain toSetOriginalLanguage "old and new languages are the same"
    fi
  else
      # log -o e "no language specified"
      askAgain toSetOriginalLanguage "no language specified"
  fi
}

function showOriginalLanguage () {
  # log -i "please wait.."

  availableLanguagesPath="./src/languages/available-languages.xml"

  lang=$(getFromXmlFile .config.xml original-language)
  # fullLang=$(getFromXmlFile $availableLanguagesPath $lang)
  fullLang=$(getLanguageName $lang)

  # oldLanguage=$(getFromXmlFile .config.xml "${name}")
  # oldLanguage=$(getFromXmlFile .config.xml en)
  # curLanguageName=$(getFromXmlFile "${availableLanguagesPath}" "${oldLanguage}")

  log -o "your current original languages is \e[1m$lang\e[0m=\e[1m(\e[0m$fullLang\e[1m)\e[0m"
  # log -o "\e[1m$lang\e[0m"
}

function printFileContent () {
  local file

  if [[ $1 != "--no-info" ]]; then
    log -i "please wait..."
    file=$1
  else
    file=$2
  fi

  if [[ -f $file ]]; then
    # log -i "file $file exists"
    echo -e $(cat $file)

    if [[ $1 != "--no-info" ]]; then
      log -o "\e[1;92m${U_DONE}${U_DONE}\e[0m done"
    fi
  fi
}


function toSpecifyLanguage () {

  origLang=$(getFromXmlFile .config.xml original-language)
  if [[ $# != 0 && $1 != $origLang ]]; then
    # TODO: check if multiple language was requested or not.
    # log -o "$1 is not the same as the original language"
    log -i "translating your \e[4mPSK App\e[24m into \e[1m$1\e[22m..."

    sleep 2

    log -o "\e[1;92m${U_DONE}${U_DONE}\e[0m done"

  elif [[ $1 = $origLang ]]; then

    askAgain toSpecifyLanguage "$1 is the same as the original language"
  else
    askAgain toSpecifyLanguage "no language specified"
  fi
}

function verifyTargetDirectory () {
  local dir=$1

  if [[ -d "$1" ]]; then
    isCustomTargetDirectory=true
    customTargetDirectory="$1"
  else
    log -o -e "\e[${E_RED}m your chosen directory(\e[1;${E_RED}m$1\e[0;${E_RED}m) does not exist\e[0m"
    exit 0
  fi
}

if [[ $# -eq 0 ]]; then
  # Translating \e[4mPSK App\e[24m to 50 different languages (by default)...

  translate
fi

while test $# -gt 0
do
  case "$1" in

    --set-orig-lang)
        toSetOriginalLanguage $2
        break
      ;;
    --show-cur-orig-lang)
        showOriginalLanguage $2
        break
      ;;
    -l | -L | --languages)
        printFileContent "src/languages/.languages"
        break
      ;;
    -v | -V | --version)
        # Print version and exit
        current_result=$(getFromXmlFile .config.xml version)
        log -o "version \e[1m$current_result\e[0m"
        break
      ;;
    "-?" | -H | --help)
        # Print help message and exit.
        printFileContent "src/help"
        break
      ;;
    -m | -M | --man)
        showManPage
        break
      ;;
    --*)
        log -o -e "invalid option ${E_START}${E_RED}${E_AND}${E_BOLD}${E_PAUSE}$1${E_END}"
        printFileContent "src/help"
        exitProgam=true
      ;;
    -*)
        log -o -e "invalid option ${E_START}${E_RED}${E_AND}${E_BOLD}${E_PAUSE}$1${E_END}"
        log -o -e "Try './polytrans.sh --help' for more information."
        exitProgam=true
      ;;
    *)
      if [[ $2 ]]; then
        # custom directory
        verifyTargetDirectory $2
      fi

      sleep 1
      if [[ ! $exitProgam ]]; then
        translate "$1"
      fi
      ;;
  esac
  shift
done

exit 0
