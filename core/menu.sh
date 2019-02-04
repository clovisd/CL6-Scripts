 #!/bin/bash
source base.sh
debug 0
logs menu

           OPTIONS="Hello Quit"
           select opt in $OPTIONS; do
               if [ "$opt" = "Quit" ]; then
                echo done
                exit
               elif [ "$opt" = "Hello" ]; then
                echo Hello World
               else
                clear
                echo bad option
               fi
           done