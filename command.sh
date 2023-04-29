#!/bin/bash
################################################################################
# Author: Fred (support@qo-op.com)
# Version: 0.1
# License: AGPL-3.0 (https://choosealicense.com/licenses/agpl-3.0/)
################################################################################
MY_PATH="`dirname \"$0\"`"
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
. "${MY_PATH}/tools/my.sh"

TS=$(date -u +%s%N | cut -b1-13)

echo '
    _    ____ _____ ____   ___  ____   ___  ____ _____    ___  _   _ _____
   / \  / ___|_   _|  _ \ / _ \|  _ \ / _ \|  _ \_   _|  / _ \| \ | | ____|
  / _ \ \___ \ | | | |_) | | | | |_) | | | | |_) || |   | | | |  \| |  _|
 / ___ \ ___) || | |  _ <| |_| |  __/| |_| |  _ < | |   | |_| | |\  | |___
/_/   \_\____/ |_| |_| \_\\___/|_|    \___/|_| \_\|_|    \___/|_| \_|_____|

Ambassade numérique pair à pair sur IPFS.

@@@@@@@@@@@@@@@@@@
ASTROPORT
VISA : MadeInZion
@@@@@@@@@@@@@@@@@@'
echo

## VERIFY SOFTWARE DEPENDENCIES
[[ ! $(which ipfs) ]] && echo "EXIT. Vous devez avoir installé ipfs CLI sur votre ordinateur" && echo "https://dist.ipfs.io/#go-ipfs" && exit 1
YOU=$(myIpfsApi);
[[ ! $YOU ]] && echo "Lancez 'ipfs daemon' SVP sudo systemctl start ipfs" && exit 1

echo 'PRESS ENTER... '; read

## CREATE AND OR CONNECT USER
    PS3='Astronaute connectez votre PLAYER  ___ '
    players=("MAKE G1PASS" "IMPORT G1PASS" $(ls ~/.zen/game/players  | grep "@" 2>/dev/null))
    ## MULTIPLAYER

    select fav in "${players[@]}"; do
        case $fav in
        "MAKE G1PASS")
            ${MY_PATH}/tools/VISA.new.sh
            fav=$(cat ~/.zen/tmp/PSEUDO 2>/dev/null) && rm ~/.zen/tmp/PSEUDO
            echo "Astronaute $fav bienvenue dans le jeu de terraformation forêt jardin MadeInZion"
            exit
            ;;
        "IMPORT G1PASS")
            echo "'Secret 1'"
            read SALT
            echo "'Secret 2'"
            read PEPPER
            echo "'Adresse Email'"
            read EMAIL
            ${MY_PATH}/tools/VISA.new.sh "$SALT" "$PEPPER" "$EMAIL"
            fav=$(cat ~/.zen/tmp/PSEUDO 2>/dev/null) && rm ~/.zen/tmp/PSEUDO
            echo "Astronaute $fav heureux de vous acceuillir"
            exit
            ;;
        "")
            echo "Choix obligatoire. exit"
            exit
            ;;
        *) echo "Salut $fav"
            break
            ;;
        esac
    done
    PLAYER=$fav


pass=$(cat ~/.zen/game/players/$PLAYER/.pass 2>/dev/null)
########################################## DEVEL
echo "Saisissez votre PASS -- UPGRADE CRYPTO FREELY -- $pass" && read PASS

## DECODE CURRENT PLAYER CRYPTO
# echo "********* DECODAGE SecuredSocketLayer *********"
# rm -f ~/.zen/tmp/${PLAYER}.dunikey 2>/dev/null
# openssl enc -aes-256-cbc -d -in "$HOME/.zen/game/players/${PLAYER}/enc.secret.dunikey" -out "$HOME/.zen/tmp/${PLAYER}.dunikey" -k $pass 2>&1>/dev/null
[[ $PASS != $pass ]] && echo "ERROR. MAUVAIS PASS. EXIT" && exit 1

rm -f ~/.zen/game/players/.current
ln -s ~/.zen/game/players/$PLAYER ~/.zen/game/players/.current

echo "________LOGIN OK____________";
echo
echo "DECHIFFRAGE CLEFS ASTRONAUTE"
echo "Votre Pass Astroport.ONE  : $(cat ~/.zen/game/players/$PLAYER/.pass 2>/dev/null)"
export G1PUB=$(cat ~/.zen/game/players/$PLAYER/secret.dunikey | grep 'pub:' | cut -d ' ' -f 2)
[ ! ${G1PUB} ] && echo "ERROR. MAUVAIS PASS. EXIT" && exit 1

echo "Clef Publque Astronaute : $G1PUB"
echo "ENTREE ACCORDEE"
echo
export ASTRONAUTENS=$(ipfs key list -l | grep -w "$PLAYER" | cut -d ' ' -f 1)

echo "$(cat ~/.zen/game/players/${PLAYER}/.pseudo 2>/dev/null) TW/Moa"
echo "$myIPFS/ipns/$ASTRONAUTENS"
echo "Activation Réseau P2P Astroport !"

[[ $XDG_SESSION_TYPE == 'x11' ]] && xdg-open "http://ipfs.localhost:8080/ipns/$ASTRONAUTENS"

echo
PS3="$PLAYER choisissez : __ "
choices=("MAKE UN VOEU" "PRINT QRVOEU" "PRINT VISA" "UNPLUG PLAYER" "QUIT")
select fav in  "${choices[@]}"; do
    case $fav in
    "PRINT VISA")
        echo "IMPRESSION"
        ${MY_PATH}/tools/VISA.print.sh "$PLAYER"
        ;;

    "UNPLUG PLAYER")
        echo "ATTENTION ${PLAYER} DECONNEXION DE VOTRE TW !!"
        echo  "Enter to continue. Ctrl+C to stop"
        read
        espeak "Droping TW in cyber space"

        ipfs key rm ${PLAYER}; ipfs key rm ${PLAYER}_feed; ipfs key rm $G1PUB;
        for vk in $(ls -d ~/.zen/game/players/${PLAYER}/voeux/*/* | rev | cut -d / -f 1 | rev); do
            ipfs key rm $vk
        done

        ## UNPLUG PLAYER DOCKER / SEE myos MODE
        [[ $USER == "zen" ]] && make player MAIL=$PLAYER DELETE=true

        #~ echo "REMOVING GCHANGE+ PROFILE"
        #~ $MY_PATH/tools/jaklis/jaklis.py -k $HOME/.zen/game/players/$PLAYER/secret.dunikey -n "$myDATA" erase
        #~ $MY_PATH/tools/jaklis/jaklis.py -k $HOME/.zen/game/players/$PLAYER/secret.dunikey -n "$myCESIUM" erase

        echo "PLAYER IPNS KEYS UNPLUGD"
        echo "rm -Rf ~/.zen/game/players/$PLAYER"
        rm -Rf ~/.zen/game/players/$PLAYER

        break
        ;;

    #~ "AJOUTER VLOG")
        #~ echo "Lancement Webcam..."
        #~ ${MY_PATH}/tools/vlc_webcam.sh "$PLAYER"
        #~ ;;

    "MAKE UN VOEU")
        echo "QRCode à coller sur les lieux ou objets portant une Gvaleur"
        cp ~/.zen/game/players/$PLAYER/ipfs/moa/index.html ~/.zen/tmp/$PLAYER.html
        ${MY_PATH}/ASTROBOT/G1Voeu.sh "" "$PLAYER" "$HOME/.zen/tmp/$PLAYER.html"
        DIFF=$(diff ~/.zen/game/players/$PLAYER/ipfs/moa/index.html ~/.zen/tmp/$PLAYER.html)
        if [[ $DIFF ]]; then
            MOATS=$(date -u +"%Y%m%d%H%M%S%4N")
            cp   ~/.zen/game/players/$PLAYER/ipfs/moa/.chain \
                    ~/.zen/game/players/$PLAYER/ipfs/moa/.chain.$(cat ~/.zen/game/players/$PLAYER/ipfs/moa/.moats)

            TW=$(ipfs add -Hq ~/.zen/game/players/$PLAYER/ipfs/moa/index.html | tail -n 1)
            ipfs name publish --allow-offline --key=$PLAYER /ipfs/$TW

            echo $TW > ~/.zen/game/players/$PLAYER/ipfs/moa/.chain
            echo $MOATS > ~/.zen/game/players/$PLAYER/ipfs/moa/.moats
        fi
    echo "================================================"
    echo "$PLAYER : $myIPFS/ipns/$ASTRONAUTENS"
    echo "================================================"
        ;;

    "PRINT QRVOEU")
        ${MY_PATH}/tools/VOEUX.print.sh $PLAYER
        ;;

    "QUIT")
        echo "CIAO" && exit 0
        ;;

    "")
        echo "Mauvais choix."
        ;;

    esac
done

exit 0
