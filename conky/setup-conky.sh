#!/bin/bash

#--- FUNCTIONS

function install-font {

  FONT=$1
  
  if fc-list | grep -i $FONT >/dev/null ; then

    echo "################################################################" 
    echo "The font "$FONT" is already available. Proceeding ...";

  else
    echo "################################################################" 
    echo "The font "$FONT" is not currently installed, would you like to install it now? (y/n)";
    read response
    if [[ "$response" =~ ^(yes|y)$ ]]; then
      echo "Installing the font to the ~/.fonts directory.";
      cp $FONT.ttf ~/.fonts
      echo "################################################################" 
      echo "Building new fonts into the cache files";
      echo "Depending on the number of fonts, this may take a while..." 
      fc-cache -fv ~/.fonts
      echo "################################################################" 
      echo "Check if the cache build was successful?";    
      if fc-list | grep -i $FONT >/dev/null; then
        echo "################################################################" 
        echo "The font was sucessfully installed!";
      else
        echo "################################################################" 
        echo "Something went wrong while trying to install the font.";
      fi
    else
      echo "################################################################"     
      echo "Skipping the installation of the font.";
      echo "Please note that this conky configuration will not work";
      echo "correctly without the font.";
    fi

  fi

}

#--- EXECUTE

[ -d $HOME"/.fonts" ] || mkdir -p $HOME"/.fonts"

FONTS=(
  "StyleBats"
  "Poky"
)

for i in "${FONTS[@]}"; do
  (
    install-font $i
  )

done # END: i loop

# TODO : script conky script choicez
echo "################################################################" 
echo "Copying conky script..."

cp alienware ~/.conkyrc 

echo "#########################################################"
echo "Conky setup finished"
echo "#########################################################"

exit $?
